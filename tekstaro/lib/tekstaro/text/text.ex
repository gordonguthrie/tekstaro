defmodule Tekstaro.Text.Text do

 use GenServer

 import Ecto.Query, warn: false
 alias Tekstaro.Repo

 alias Tekstaro.Text.Text, as: State
 alias Tekstaro.Text.Texts
 alias Tekstaro.Text.Paragraph

 @registry :text_registry

 defstruct [
            name:            "",
            texts:           "",
            status:          "",
            raw_paragraphs:  "",
						paragraphs:      "",
            last_touched:    "",
            username:        ""
           ]

  #
  # Gen Server callbacks
  #

  def start_link({name, username}) do
    GenServer.start_link(__MODULE__, {name, username}, name: via(name))
  end

  @impl true
  def init({name, username}) do
    %Tekstaro.Accounts.User{username: uname} = username
    texts = %{url:         "",
              site:        "",
              title:       "",
              text:        "",
              fingerprint: "",
              username:    uname}
    {:ok, %State{name: name, status: "inited", texts: texts}}
  end

  @impl true
  def handle_call(:get_status, _from, %State{status: status} = state) do
    {:reply, status, state}
  end

  @impl true
  def handle_cast({:load, text, title, url, site}, %State{name: name, texts: texts} = state) do
    canonical = String.trim(text)
    fingerprint = :crypto.hash(:sha256, [canonical])
                  |> Base.encode16
                  |> String.downcase
    case Repo.get_by(Texts, fingerprint: fingerprint) do
      nil ->
        TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "loaded"})
        :ok = GenServer.cast(via(name), :save_texts)
        newtexts = %{texts | url:         url,
                             site:        site,
                             title:       title,
                             text:        canonical,
                             fingerprint: fingerprint}
        {:noreply, %{state | texts:        newtexts,
                             status:       "loaded",
                             last_touched: now()}}
        _ ->
          TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "text already saved"})
          :ok = GenServer.cast(via(name), :terminate)
          {:noreply, state}
      end
  end
  def handle_cast(:split_text, %State{name: name, texts: texts} = state) do
    %{text: text} = texts
    paragraphs = Procezo.estigu_paragrafoj(text)
    length = length(paragraphs)
    msg = "split text up" <> Integer.to_string(length)
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: msg})
    :ok = GenServer.cast(via(name), :process_paragraph)
    {:noreply, %{state | raw_paragraphs: paragraphs,
                         status:         "split",
                         last_touched:   now()}}
  end
  def handle_cast(:process_paragraph, %State{name: name, raw_paragraphs: []} = state) do
		# we don't reverse the paragraph list because the raw paragraphs came to us already reversed
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "processed all the paragraphs"})
    :ok = GenServer.cast(via(name), :ready_to_save)
    {:noreply, %{state | status:       "ready to save",
                         last_touched: now()}}
  end
  def handle_cast(:process_paragraph, %State{name:           name,
																						 paragraphs:     ps,
																					   raw_paragraphs: [h | t]} = state) do
		p = GenServer.call(Tekstaro.Text.Vortoj, {:process, h})
		%Paragrafo{paragrafo:         paragrafo,
               identaĵo:          fingerprint,
               intersekvo:        i,
	             neniu_de_vortoj:   nv,
               neniu_de_gravuloy: ng,
               radikigoj:         r} = p
    para = %{fingerprint:      fingerprint,
             text:             paragrafo,
             sequence:         i,
             no_of_words:      nv,
             no_of_characters: ng}
    result = %Paragraph{}
              |> Paragraph.changeset(para)
              |> Repo.insert()
    msg = case result do
      {:error, _e} ->
        "paragraph " <> Integer.to_string(i) <> " already written"
      {:ok, _other} ->
        "paragraph " <> Integer.to_string(i) <> " of " <> Integer.to_string(ng)
    					<> " split into " <> Integer.to_string(nv) <> " words"
      end
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: msg})
    :ok = write_words(r, fingerprint)
    :ok = GenServer.cast(via(name), :process_paragraph)
    {:noreply, %{state | paragraphs:       [p | ps],
												 raw_paragraphs:   t,
                         status:           "split",
                         last_touched:     now()}}
  end
  def handle_cast(:save_texts, %State{name:  name,
                                      texts: texts} = state) do
    result = %Texts{}
              |> Texts.changeset(texts)
              |> Repo.insert()
    {msg, next_step} = case result do
      {:error, _e} ->
        {"text already submitted", :terminate}
      {:ok, _other} ->
        {"text written to disk (but not paras)",  :split_text}
      end
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: msg})
    :ok = GenServer.cast(via(name), next_step)
    {:noreply, state}
  end
  def handle_cast(something, state) do
    IO.inspect(something, label: "not handling")
    {:noreply, state}
  end

  #
  # API for the regsitered modules
  #

  def start_child(text, title, url, site, username) do
    # we used a hash as an ID in case the person resubmits
    # but internally we use a separate hash to identify a text
    # the internal has is only approximate because trivial editing
    # (eg adding a whie space at either end, including front matter)
    # will give a new hash
    # the hash we really rely on is the per-paragraph hash on the
    # canonicalised paragraphs
    hash = :crypto.hash(:sha256, [title, url, text, now()])
           |> Base.encode16
           |> String.downcase
    name = "text:" <> hash
    {:ok, _pid} = Tekstaro.Text.TextSupervisor.start_child({name, username})
    :ok = GenServer.cast(via(name), {:load, text, title, url, site})
    name
  end

  def get_status(name) do
    GenServer.call(via(name), :get_status)
  end

  #
  # private functions
  #

  defp write_words([], _fingerprint), do: :ok
  defp write_words([h | t], fingerprint) do
    IO.inspect(h, label: "writing word")
    write_words(t, fingerprint)
  end

  defp via(name), do: {:via, Registry, {@registry, name} }

  defp now() do
    {:ok, d} = DateTime.now("Etc/UTC")
    DateTime.to_string(d)
  end

end
