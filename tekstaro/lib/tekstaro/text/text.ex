defmodule Tekstaro.Text.Text do
  use GenServer

  import Ecto.Query, warn: false
  alias Tekstaro.Repo

  alias Tekstaro.Text.Text, as: State
  alias Tekstaro.Text.Texts
  alias Tekstaro.Text.Paragraph
  alias Tekstaro.Text.Word
  alias Tekstaro.Text.Affix

  @registry :text_registry

  defstruct name:           "",
            texts:          "",
            texts_id:        0,
            status:         "",
            raw_paragraphs: "",
            paragraphs:     "",
            last_touched:   "",
            username:       ""

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

    fingerprint =
      :crypto.hash(:sha256, [canonical])
      |> Base.encode16()
      |> String.downcase()

    case Repo.get_by(Texts, fingerprint: fingerprint) do
      nil ->
        TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "loaded"})
        :ok = GenServer.cast(via(name), :save_texts)

        newtexts = %{
          texts
          | url:         url,
            site:        site,
            title:       title,
            text:        canonical,
            fingerprint: fingerprint
        }

        {:noreply, %{state | texts: newtexts, status: "loaded", last_touched: now()}}

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
    {:noreply, %{state
                 | raw_paragraphs: paragraphs,
                   status:         "split",
                   last_touched:   now()}}
  end

  def handle_cast(:process_paragraph, %State{name: name, raw_paragraphs: []} = state) do
    # we don't reverse the paragraph list because the raw paragraphs came to us already reversed
    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: "processed all the paragraphs"})
    :ok = GenServer.cast(via(name), :ready_to_save)
    {:noreply, %{state
                 | status:      "ready to save",
                   last_touched: now()}}
  end

  def handle_cast(
        :process_paragraph,
        %State{name:    name,
        texts_id:       texts_id,
        paragraphs:     ps,
        raw_paragraphs: [h | t]} = state
      ) do
    p = GenServer.call(Tekstaro.Text.Vortoj, {:process, h})

    %Paragrafo{
      paragrafo:         paragraph,
      identaĵo:          fingerprint,
      intersekvo:        i,
      neniu_de_vortoj:   no_of_words,
      neniu_de_gravuloy: no_of_characters,
      radikigoj:         r
    } = p

    para = %{
      fingerprint:      fingerprint,
      text:             paragraph,
      texts_id:         texts_id,
      sequence:         i,
      no_of_words:      no_of_words,
      no_of_characters: no_of_characters
    }

    result =
      %Paragraph{}
      |> Paragraph.changeset(para)
      |> Repo.insert()

    msg =
      case result do
        {:error, _e} ->
          "paragraph " <> Integer.to_string(i) <> " already written"

        {:ok, _other} ->
          "paragraph " <>
            Integer.to_string(i) <>
            " of " <>
            Integer.to_string(no_of_characters) <>
            " characters split into " <> Integer.to_string(no_of_words) <> " words"
      end

    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: msg})
    :ok = write_words(r, fingerprint)
    :ok = GenServer.cast(via(name), :process_paragraph)

    {:noreply, %{state
                 | paragraphs:     [p | ps],
                   raw_paragraphs: t,
                   status:         "split",
                   last_touched:   now()}}
  end

  def handle_cast(
        :save_texts,
        %State{name: name, texts: texts} = state
      ) do
    result =
      %Texts{}
      |> Texts.changeset(texts)
      |> Repo.insert()

    {msg, next_step, id} =
      case result do
        {:error, _e} ->
          {"text already submitted", :terminate, 0}
        {:ok, write} ->
          %Tekstaro.Text.Texts{id: id} = write
          IO.inspect(write, label: "successful write")
          {"text written to disk (but not paras)", :split_text, id}
      end

    TekstaroWeb.Endpoint.broadcast(name, "status", %{status: msg})
    :ok = GenServer.cast(via(name), next_step)
    {:noreply, %{state | texts_id: id}}
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
    hash =
      :crypto.hash(:sha256, [title, url, text, now()])
      |> Base.encode16()
      |> String.downcase()

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
    %Radikigo{
      vorto:            unnormalised_word,
      radikigo:         root,
      detaletoj:        details,
      afiksoj:          affixes,
      ekesto:           starting_position,
      longaĵo:          word_length,
      estas_vortarero?: is_a_dictionary_word
    } = h

    is_dictionary_word = translate_boolean(is_a_dictionary_word)
    record = %{
      fingerprint:         fingerprint,
      word:                String.downcase(unnormalised_word),
      root:                root,
      starting_position:   starting_position,
      length:              word_length,
      is_dictionary_word?: is_dictionary_word,
      is_adjective?:       false,
      is_noun?:            false,
      is_verbal?:          false,
      is_adverb?:          false,
      is_correlative?:     false,
      is_pronoun?:         false,
      is_krokodile?:       false,
      is_small_word?:      false,
      case_marked?:        false,
      number_marked?:      false,
      is_nickname?:        false,
      is_possesive?:       false,
      form:                "infinitive",
      voice:               "active",
      aspect:              "none",
      is_participle?:      false,
      is_perfect?:         false
    }

    record2 = decorate_record(details, record)
    {:ok, result} =
      %Word{}
      |> Word.changeset(record2)
      |> Repo.insert()
    %Word{id: id} = result
    :ok = write_affixes(affixes, id)
    write_words(t, fingerprint)
  end

  defp write_affixes([], _id), do: :ok
  defp write_affixes([h | t], id) do
    IO.inspect({id, h}, label: "affix")
    {affix, type, no} = process_affix(h)
    a = %{word_id:  id,
          affix:    affix,
          type:     type,
          position: no}
   {:ok, _result} =
        %Affix{}
        |> Affix.changeset(a)
        |> Repo.insert()
    write_affixes(t, id)
  end

  defp process_affix(%Afikso{nombro: n, postfikso: :nil, prefikso: affix}) do
    {affix, "prefix", n}
  end
  defp process_affix(%Afikso{nombro: n, postfikso: affix, prefikso: :nil}) do
    {affix, "postfix", n}
  end

  defp decorate_record([], record) do
    record
  end
  defp decorate_record([%Ovorto{} = h | t], record) do
    %Ovorto{kazo:            case_marked,
            nombro:          number,
            estas_karesnomo: is_nickname} = h
    new = %{
      record
      | is_noun?: true,
        case_marked?:   translate_case(case_marked),
        number_marked?: translate_number(number),
        is_nickname?:   translate_boolean(is_nickname)
    }
    decorate_record(t, new)
  end
  defp decorate_record([%Avorto{} = h | t], record) do
    %Avorto{kazo:            case_marked,
            nombro:          number} = h
    new = %{
      record
      | is_adjective?:  true,
        case_marked?:   translate_case(case_marked),
        number_marked?: translate_number(number)
    }
    decorate_record(t, new)
  end
  defp decorate_record([%Evorto{} = h | t], record) do
    %Evorto{kazo: case_marked} = h
    new = %{
      record
      | is_adverb?:   true,
        case_marked?: translate_case(case_marked)
    }
    decorate_record(t, new)
  end
  defp decorate_record([%Korelatevo{} = h | t], record) do
    %Korelatevo{kazo: case_marked} = h
    new = %{
      record
      | is_correlative?: true,
        case_marked?:    translate_case(case_marked)
    }
    decorate_record(t, new)
  end
  defp decorate_record([%Pronomo{} = h | t], record) do
    %Pronomo{estas_poseda: is_possessive,
             kazo:         case_marked,
             nombro:       number} = h
             new = %{
               record
               | is_pronoun?:    true,
                 case_marked?:   translate_case(case_marked),
                 number_marked?: translate_number(number),
                 is_possesive?:  translate_boolean(is_possessive)
             }
     decorate_record(t, new)
  end
  defp decorate_record([:malgrandavorto | t], record) do
    new = %{
      record
      | is_small_word?: true
    }
    decorate_record(t, new)
  end
  defp decorate_record([:krokodilo | t], record) do
      new = %{
        record
        | is_krokodile?: true
      }
      decorate_record(t, new)
  end
  defp decorate_record([%Verbo{} = h | t], record) do
    %Verbo{
           formo:          form,
           voĉo:           voice,
           aspecto:        aspect,
           estas_partipo:  is_participle,
           estas_perfekto: is_perfect} = h
           new = %{
             record
             | form:           translate_form(form),
               voice:          translate_voice(voice),
               aspect:         translate_aspect(aspect),
               is_participle?: translate_boolean(is_participle),
               is_perfect?:    translate_boolean(is_perfect)
           }
    decorate_record(t, new)
  end

  defp translate_voice(:aktiva), do: "active"
  defp translate_voice(:pasiva), do: "passive"

  defp translate_aspect(:nil),      do: "nil"
  defp translate_aspect(:ekestiĝa), do: "in-play"
  defp translate_aspect(:finita),   do: "finished"
  defp translate_aspect(:anticipa), do: "anticipated"

  defp translate_form(:infinitiva), do: "infinive"
  defp translate_form(:nuna),       do: "present"
  defp translate_form(:futuro),     do: "future"
  defp translate_form(:estinta),    do: "past"
  defp translate_form(:kondiĉa),    do: "conditional"
  defp translate_form(:imperativa), do: "imperative"
  defp translate_form(:participa),  do: "participle"
  defp translate_form(:radikigo),   do: "radical"

  defp translate_case(:markita),    do: true
  defp translate_case(:malmarkita), do: false

  defp translate_number(:sola),  do: false
  defp translate_number(:plura), do: true

  defp translate_boolean(:jes), do: true
  defp translate_boolean(:ne),  do: false

  defp via(name), do: {:via, Registry, {@registry, name}}

  defp now() do
    {:ok, d} = DateTime.now("Etc/UTC")
    DateTime.to_string(d)
  end
end
