defmodule Tekstaro.Text.Text do
	
 use GenServer
 alias Tekstaro.Text.Text, as: State

 @registry :text_registry

 defstruct [
            name:         "",
            hash:         "",
            url:          "",
            title:        "",
            text:         "",
            status:       "",
            fingerprint:  "",
            paragraphs:   "",
            last_touched: ""
           ]

  #
  # Gen Server callbacks
  #

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  @impl true
  def init(name) do
    {:ok, %State{name: name, status: "inited"}}
  end

  @impl true
  def handle_call(:get_status, _from, %State{status: status} = state) do
    {:reply, status, state}
  end

  @impl true
  def handle_cast({:load, text, title, url}, %State{name: name} = state) do
    hash = :crypto.hash(:sha256, [text])
           |> Base.encode16
           |> String.downcase
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "loaded"})
    :ok = GenServer.cast(via(name), :split_text)
    {:noreply,  %{state | hash:         hash,
                          url:          url, 
                          title:        title, 
                          text:         text,
                          status:       "loaded", 
                          last_touched: now()}}
  end
  def handle_cast(:split_text, %State{name: name, text: text} = state) do
    paragraphs = Precipa.dividu_teksto(text)
    length = length(paragraphs)
    msg = "split text up" <> Integer.to_string(length)
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: msg})
    :ok = GenServer.cast(via(name), :process_paragraph)
    {:noreply,  %{state | paragraphs:   paragraphs,
                          status:       "split", 
                          last_touched: now()}}
  end
  def handle_cast(:process_paragraph, %State{paragraph: []} = state) do
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "processed all the paragraphs"})
    :ok = GenServer.cast(via(name), :ready_to_save)
    {:noreply,  %{state | status:       "ready to save", 
                          last_touched: now()}}
  end
  def handle_cast(:process_paragraph, %State{paragraphs: [h | t]} = state) do
    paragraphs = Precipa.dividu_teksto(text)
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "split text up"})
    :ok = GenServer.cast(via(name), :process_paragraph)
    {:noreply,  %{state | paragraphs:   t,
                          status:       "split", 
                          last_touched: now()}}
  end
  def handle_cast(something, state) do
    IO.inspect(something, label: "not handling")
    {:noreply, state}
  end

  #
  # API for the regsitered modules
  #

  def start_child(text, title, url) do
    # we used a hash as an ID in case the person resubmits
    # but internally we use a separate hash to identify a text
    # the internal has is only approximate because trivial editing
    # (eg adding a whie space at either end, including front matter)
    # will give a new hash
    # the hash we really rely on is the per-paragraph hash on the
    # canonicalised paragraphs
    hash = :crypto.hash(:sha256, [title, url, text])
           |> Base.encode16
           |> String.downcase
    name = "text:" <> hash
    {:ok, _pid} = Tekstaro.Text.TextSupervisor.start_child(name)
    :ok = GenServer.cast(via(name), {:load, text, title, url})
    name
  end

  def get_status(name) do
    GenServer.call(via(name), :get_status)
  end
  #
  # private functions
  #

  defp via(name), do: {:via, Registry, {@registry, name} }

  def now() do
    {:ok, d} = DateTime.now("Etc/UTC")
    d
  end

end