defmodule TekstaroWeb.SearchController do
  use TekstaroWeb, :controller

  alias Tekstaro.Text.Translate

  def parse(conn, %{"search_term" => s, "locale" => locale} = params) do
    Gettext.put_locale(locale)
    raw_paragraphs = Procezo.estigu_paragrafoj(s)
    paragraphs = for p <- raw_paragraphs, do: GenServer.call(Tekstaro.Text.Vortoj, {:process, p})
    results = get_parse_results(paragraphs)
    conn
    |> render("parse.json", results: results, search_terms: s)
  end

  def search(conn, %{"search_term" => s} = _params) do
    raw_paragraphs = Procezo.estigu_paragrafoj(s)
    paragraphs = for p <- raw_paragraphs, do: GenServer.call(Tekstaro.Text.Vortoj, {:process, p})
    words = get_words(paragraphs)
    {sql, search_terms} = make_sql(words)
    response = Ecto.Adapters.SQL.query!(Tekstaro.Repo, sql)
    %Postgrex.Result{rows: rows} = response
    conn
    |> render("search.json", results: rows, search_terms: search_terms)
  end

  defp get_parse_results(paragraphs) do
    terms = for p <- paragraphs do
      %Paragrafo{radikigoj: radikigoj} = p
      for %Radikigo{vorto:            word,
                    radikigo:         root,
                    estas_vortarero?: is_dictionary_word,
                    afiksoj:          affixes,
                    detaletoj:        details} <- radikigoj do
      details2 = translate_details(details, [])
      affixes2 = translate_affixes(affixes)
      note = case is_dictionary_word do
          :jes -> gettext("A dictionary word.")
          :ne  -> gettext("Not a dictionary word.")
      end
      %{"word"    => word,
        "root"    => root,
        "note"    => note,
        "details" => details2,
        "affixes" => affixes2}
      end
    end
    _terms2 = Enum.reverse(List.flatten(terms))
  end

  defp get_words(paragraphs) do
    terms = for p <- paragraphs do
      %Paragrafo{radikigoj: radikigoj} = p
        for %Radikigo{vorto: word, radikigo: root} <- radikigoj, do: {word, root}
    end
    _terms2 = List.flatten(terms)
  end

  defp translate_details([], acc), do: acc
  defp translate_details([%Verbo{} = h | t], acc) do
    translate_details(t, [Translate.translate_verbo(h) | acc])
  end
  defp translate_details([%Ovorto{} = h | t], acc) do
    translate_details(t, [Translate.translate_ovorto(h) | acc])
  end
  defp translate_details([%Evorto{} = h | t], acc) do
    translate_details(t, [Translate.translate_evorto(h) | acc])
  end
  defp translate_details([%Pronomo{} = h | t], acc) do
    translate_details(t, [Translate.translate_pronomo(h) | acc])
  end
  defp translate_details([%Avorto{} = h | t], acc) do
    translate_details(t, [Translate.translate_avorto(h) | acc])
  end
  defp translate_details([%Korelatevo{} = h | t], acc) do
    translate_details(t, [Translate.translate_korelatevo(h) | acc])
  end
  defp translate_details([:krokodilo | t], acc) do
    translate_details(t, [gettext("Krokodilo") | acc])
  end
  defp translate_details([:malgrandavorto | t], acc) do
    translate_details(t, [gettext("Small word") | acc])
  end

  defp translate_affixes(affixes) do
    for a <- affixes, do: translate_affix(a)
  end

  defp translate_affix(%Afikso{prefikso: "bo"}),  do: %{element: "bo", meaning: gettext("Prefix: in-law")}
  defp translate_affix(%Afikso{prefikso: "ek"}),  do: %{element: "ek", meaning: gettext("Prefix: on set of action (in verbs)")}
  defp translate_affix(%Afikso{prefikso: "fi"}),  do: %{element: "fi", meaning: gettext("Prefix: low (moral) quality")}
  defp translate_affix(%Afikso{prefikso: "ge"}),  do: %{element: "ge", meaning: gettext("Prefix: both men and women")}
  defp translate_affix(%Afikso{prefikso: "re"}),  do: %{element: "re", meaning: gettext("Prefix: repetition or restoration")}

  defp translate_affix(%Afikso{prefikso: "dis"}),  do: %{element: "dis", meaning: gettext("Prefix: dispersion in all directions")}
  defp translate_affix(%Afikso{prefikso: "eks"}),  do: %{element: "eks", meaning: gettext("Prefix: former, ex")}
  defp translate_affix(%Afikso{prefikso: "mal"}),  do: %{element: "mal", meaning: gettext("Prefix: reversal of meaning")}
  defp translate_affix(%Afikso{prefikso: "mis"}),  do: %{element: "mis", meaning: gettext("Prefix: malfunction")}
  defp translate_affix(%Afikso{prefikso: "pra"}),  do: %{element: "pra", meaning: gettext("Prefix: old, antique")}

  defp translate_affix(%Afikso{postfikso: "aĉ"}),   do: %{element: "aĉ", meaning: gettext("Postfix: poor quality")}
  defp translate_affix(%Afikso{postfikso: "ad"}),   do: %{element: "ad", meaning: gettext("Postfix: the duration of an action")}
  defp translate_affix(%Afikso{postfikso: "aĵ"}),   do: %{element: "aĵ", meaning: gettext("Postfix: concrete object or product or behaviour")}
  defp translate_affix(%Afikso{postfikso: "an"}),   do: %{element: "an", meaning: gettext("Postfix: a member of a group")}
  defp translate_affix(%Afikso{postfikso: "ar"}),   do: %{element: "ar", meaning: gettext("Postfix: a group")}

  defp translate_affix(%Afikso{postfikso: "ec"}),   do: %{element: "ec", meaning: gettext("Postfix: abstract quality, trait, attribute or essence")}
  defp translate_affix(%Afikso{postfikso: "eg"}),   do: %{element: "eg", meaning: gettext("Postfix: increase in strength or size")}
  defp translate_affix(%Afikso{postfikso: "em"}),   do: %{element: "em", meaning: gettext("Postfix: to tend towards")}
  defp translate_affix(%Afikso{postfikso: "er"}),   do: %{element: "er", meaning: gettext("Postfix: a single instance")}
  defp translate_affix(%Afikso{postfikso: "et"}),   do: %{element: "et", meaning: gettext("Postfix: decrease in strength or size")}
  defp translate_affix(%Afikso{postfikso: "ej"}),   do: %{element: "ej", meaning: gettext("Postfix: a place")}

  defp translate_affix(%Afikso{postfikso: "id"}),   do: %{element: "id", meaning: gettext("Postfix: offspring")}
  defp translate_affix(%Afikso{postfikso: "ig"}),   do: %{element: "ig", meaning: gettext("Postfix: makes transitive verbs intransitive, denotes becoming")}
  defp translate_affix(%Afikso{postfikso: "iĝ"}),   do: %{element: "iĝ", meaning: gettext("Postfix: makes intransitive verbs transitive (and add an object to transative vers)")}
  defp translate_affix(%Afikso{postfikso: "il"}),   do: %{element: "il", meaning: gettext("Postfix: something to do it, an instrument")}
  defp translate_affix(%Afikso{postfikso: "ik"}),   do: %{element: "ik", meaning: gettext("Postfix: -ics")}
  defp translate_affix(%Afikso{postfikso: "in"}),   do: %{element: "in", meaning: gettext("Postfix: female")}
  defp translate_affix(%Afikso{postfikso: "iv"}),   do: %{element: "in", meaning: gettext("Postfix: capabile of doing...")}

  defp translate_affix(%Afikso{postfikso: "on"}),   do: %{element: "bo", meaning: gettext("Postfix: makes fractions (for numbers)")}
  defp translate_affix(%Afikso{postfikso: "op"}),   do: %{element: "op", meaning: gettext("Postfix: at a time (for numbers)")}
  defp translate_affix(%Afikso{postfikso: "oz"}),   do: %{element: "oz", meaning: gettext("Postfix: full of")}

  defp translate_affix(%Afikso{postfikso: "uj"}),   do: %{element: "uj", meaning: gettext("Postfix: the territory of, a container that fully encloses")}
  defp translate_affix(%Afikso{postfikso: "ul"}),   do: %{element: "ul", meaning: gettext("Postfix: a person")}
  defp translate_affix(%Afikso{postfikso: "um"}),   do: %{element: "um", meaning: gettext("Postfix: to make quirky verbs from nouns")}

  defp translate_affix(%Afikso{postfikso: "ebl"}),  do: %{element: "ebl", meaning: gettext("Postfix: the possibility, -able")}
  defp translate_affix(%Afikso{postfikso: "end"}),  do: %{element: "end", meaning: gettext("Postfix: necessary")}
  defp translate_affix(%Afikso{postfikso: "esk"}),  do: %{element: "end", meaning: gettext("Postfix: -esque")}
  defp translate_affix(%Afikso{postfikso: "foj"}),  do: %{element: "foj", meaning: gettext("Postfix: times (for numbers, 3 times, 4 times)")}
  defp translate_affix(%Afikso{postfikso: "ind"}),  do: %{element: "ind", meaning: gettext("Postfix: worthy of")}
  defp translate_affix(%Afikso{postfikso: "ing"}),  do: %{element: "ing", meaning: gettext("Postfix: container, partially containing")}
  defp translate_affix(%Afikso{postfikso: "ism"}),  do: %{element: "ism", meaning: gettext("Postfix: an -ism")}
  defp translate_affix(%Afikso{postfikso: "ist"}),  do: %{element: "ist", meaning: gettext("Postfix: someone who does")}
  defp translate_affix(%Afikso{postfikso: "obl"}),  do: %{element: "obl", meaning: gettext("Postfix: multiple of quantities (for numbers)")}

  defp translate_affix(%Afikso{postfikso: "estr"}), do: %{element: "estr", meaning: gettext("Postfix: chief of")}
  defp translate_affix(%Afikso{postfikso: "olog"}), do: %{element: "estr", meaning: gettext("Postfix: -ology")}

  defp make_sql(terms) do
    # some words are consumed by their parts and don't have roots
    # eg `a` or `igo`
    clauses = for {word, root} <- terms do
        case root do
          "" -> "word.word = '" <> word <> "'"
          _  -> "word.root = '" <> root <> "'"
        end
    end
    search_terms = for {word, root} <- terms do
        case root do
          "" -> word
          _  -> root
        end
    end
    sql = """
    SELECT paragraph.text, word.starting_position, word.length FROM word
    INNER JOIN paragraph ON word.fingerprint = paragraph.fingerprint
    WHERE
    """ <> Enum.join(clauses, " OR ") <> "  LIMIT 15;"
    {sql, Enum.sort(search_terms)}
  end

end
