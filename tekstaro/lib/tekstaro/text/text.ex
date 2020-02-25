defmodule Tekstaro.Text.Text do
	
 use GenServer
 alias Tekstaro.Text.Text, as: State

 @registry :text_registry

 defstruct [
            name:         "",
            url:          "",
            title:        "",
            text:         "",
            fingerprint:  "",
            paragraphs:   "",
            last_touched: ""
           ]

  #
  # Gen Server callbacks
  #

  def start_link(hash) do
    GenServer.start_link(__MODULE__, hash, name: via(hash))
  end

  @impl true
  def init(name) do
    IO.inspect(name, label: "initing text gen server with")
    {:ok, %State{name: name}}
  end

  @impl true
  def handle_call({:load, text, title, url}, _from, %State{} = state) do
  	IO.inspect(text, label: "in text gen server")
  	IO.inspect(title, label: "with title")
  	IO.inspect(url, label: "with url")
  	# response = Procezo.procezu(text, title, url, "Gordon Guthrie")
    # IO.inspect(response)

    {:reply, :ok, %{state | url: url, title: title, text: text, last_touched: now()}}
  end

  #
  # API for the regsitered modules
  #

  def start_child(text, title, url) do
    {:ok, d} = DateTime.now("Etc/UTC")
    date = DateTime.to_string(d)
    hash = :crypto.hash(:sha256, [date, title, url, text])
           |> Base.encode16
           |> String.downcase
    IO.inspect(hash, label: "got hash")
    ret = Tekstaro.Text.TextSupervisor.start_child(hash)
    IO.inspect(ret, label: "text started with")
    :ok = GenServer.call(via(hash), {:load, text, title, url})
    ret
  end

  defp via(name), do: {:via, Registry, {@registry, name} }


  def now() do
    {:ok, d} = DateTime.now("Etc/UTC")
    d
  end

end