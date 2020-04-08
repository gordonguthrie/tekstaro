defmodule TekstaroWeb.SearchController do
  use TekstaroWeb, :controller

  alias Tekstaro.Text.Translate

  def browse(conn, %{"postfixes" => postfixes}) do
    browse_affixes(conn, postfixes)
  end

  def browse(conn, %{"prefixes" => postfixes}) do
    browse_affixes(conn, postfixes)
  end

  def browse(conn, params) do
    sql = make_browse_sql(params);
    response = Ecto.Adapters.SQL.query!(Tekstaro.Repo, sql)
    %Postgrex.Result{rows: rows} = response
    rows2 = process_rows(rows)
    conn
    |> render("browse.json", results: rows2)
  end

  defp browse_affixes(conn, affixes) do
    sql = make_affix_sql(affixes);
    response = Ecto.Adapters.SQL.query!(Tekstaro.Repo, sql)
    %Postgrex.Result{rows: rows} = response
    rows2 = process_rows(rows)
    conn
    |> render("browse.json", results: rows2)

  end

  def parse(conn, %{"search_term" => s} = _params) do
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
    {sql, _search_terms} = make_search_sql(words)
    response = Ecto.Adapters.SQL.query!(Tekstaro.Repo, sql)
    %Postgrex.Result{rows: rows} = response
    rows2 = process_rows(rows)
    conn
    |> render("search.json", results: rows2, search_terms: s)
  end

  defp process_rows(rows) do
    for [word | t] <- rows do
      raw_paragraphs = Procezo.estigu_paragrafoj(word)
      paragraphs = for p <- raw_paragraphs, do: GenServer.call(Tekstaro.Text.Vortoj, {:process, p})
      [w] = get_parse_results(paragraphs)
      [w | t]
    end
  end

  defp get_parse_results(paragraphs) do
    terms = for p <- paragraphs do
      %Paragrafo{radikigoj: radikigoj} = p
      for %Radikigo{vorto:            word,
                    radikigo:         root,
                    afiksoj:          affixes,
                    detaletoj:        details} <- radikigoj do
      details2 = translate_details(details, [])
      affixes2 = translate_affixes(affixes)
      sql = "SELECT is_verb, is_transitive, is_intransitive, etymology FROM dictionary WHERE root='" <> root <> "';"
      matches = Ecto.Adapters.SQL.query!(Tekstaro.Repo, sql)
      note = case matches.rows do
        []                       -> ""
        [[is_v, is_t, is_i, et]] ->
          notes = case is_v do
            true  -> v2 = gettext("Verb root")
                       case {is_t, is_i} do
                         {true,  true}  -> [et, v2, gettext("Transitive"), gettext("Intransitive")]
                         {true,  false} -> [et, v2, gettext("Transitive")]
                         {false, true}  -> [et, v2, gettext("Intransitive")]
                       end
            false -> [et, gettext("Noun root")]
          end
          Enum.join(notes, ". ") <> "."
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
    translate_details(t, ["Krokodilo" | acc])
  end
  defp translate_details([:malgrandavorto | t], acc) do
    translate_details(t, [gettext("Small word") | acc])
  end

  defp translate_affixes(affixes) do
    for a <- affixes, do: translate_affix(a)
  end

  defp translate_affix(%Afikso{prefikso: "bo"}),  do: %{element: "bo", meaning: gettext("Prefix: in-law")}
  defp translate_affix(%Afikso{prefikso: "ek"}),  do: %{element: "ek", meaning: gettext("Prefix: onset of action (in verbs)")}
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
  defp translate_affix(%Afikso{postfikso: "iĝ"}),   do: %{element: "iĝ", meaning: gettext("Postfix: makes intransitive verbs transitive (and add an object to transative verbs)")}
  defp translate_affix(%Afikso{postfikso: "ik"}),   do: %{element: "ik", meaning: gettext("Postfix: -ics")}
  defp translate_affix(%Afikso{postfikso: "il"}),   do: %{element: "il", meaning: gettext("Postfix: something to do it, an instrument")}
  defp translate_affix(%Afikso{postfikso: "in"}),   do: %{element: "in", meaning: gettext("Postfix: female")}
  defp translate_affix(%Afikso{postfikso: "iv"}),   do: %{element: "iv", meaning: gettext("Postfix: capable of doing...")}

  defp translate_affix(%Afikso{postfikso: "on"}),   do: %{element: "on", meaning: gettext("Postfix: makes fractions (for numbers)")}
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

  defp make_affix_sql(affixes) do

    cursor = get_cursor()

    wheres = for a <- affixes do
      "affix.affix='" <> a <> "'"
    end

    where_clauses = case wheres do
        [] -> []
        _  -> "(" <> Enum.join(wheres, " OR ") <> ")"
      end

    _sql = """
    SELECT
    word.word,
    texts.title,
    texts.site,
    paragraph.text,
    paragraph.sequence,
    word.starting_position,
    word.length
    FROM
      public.paragraph
    INNER JOIN
      word ON
      word.fingerprint = paragraph.fingerprint
    INNER JOIN
      texts ON
      paragraph.texts_id = texts.id
    INNER JOIN
      affix ON
      affix.word_id = word.id
    WHERE
      paragraph.fingerprint >
    """  <> "'" <> cursor <> "'" <>
    " AND " <>
    where_clauses <>
     " LIMIT 15;"
  end

  defp make_browse_sql(%{"type"               => t,
                         "booleans"           => b} = terms) do

    type = "word." <> t <> "=true"

    cursor = get_cursor()

    ors1 = case Map.has_key?(terms, "aspect") do
      true  -> %{"aspect"   => a} = terms
                make_ors("aspect", a)
      false -> []
    end

    ors2 = case Map.has_key?(terms, "form") do
      true  -> %{"form" => f} = terms
                make_ors("form", f)
      false -> []
    end

    ors3 = case Map.has_key?(terms, "voice") do
      true  -> %{"voice" => v} = terms
                make_ors("voice", v)
      false -> []
    end

    ors4 = for {k, v} <- b, do: k <> "='" <> v <> "'"
    ors4X = case ors4 do
      [] -> []
      _  -> "(" <> Enum.join(ors4, " AND ") <> ")"
    end

    orsX = List.flatten([ors1, ors2, ors3, ors4X])
    ors = case orsX do
      [] -> []
      _  ->  "(" <> Enum.join(orsX, " OR ") <> ")"
    end

    where_clauses = Enum.join(List.flatten([type, ors]), " AND ")

    _sql = """
    SELECT
    word.word,
    texts.title,
    texts.site,
    paragraph.text,
    paragraph.sequence,
    word.starting_position,
    word.length
    FROM
      public.paragraph
    INNER JOIN
      word ON
      word.fingerprint = paragraph.fingerprint
    INNER JOIN
      texts ON
      paragraph.texts_id = texts.id
    WHERE
      paragraph.fingerprint >
    """  <> "'" <> cursor <> "'" <>
    " AND " <>
    where_clauses <>
     " LIMIT 15;"
  end

  defp make_browse_sql(%{"type"    => t} = _terms) do
      make_browse_sql(%{"type"     => t,
                        "booleans" => []})
  end
  defp make_browse_sql(%{"type"     => "is_krokodile"} = _terms) do
       make_browse_sql(%{"type"     => "is_krokodile",
                         "booleans" => []})
  end

  defp make_search_sql(terms) do
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

    cursor = get_cursor()

    # remember we are destructing the returned results
    # using the order fields are specified in this query
    # edit this query and you need to edit search_view.ex
    sql = """
    SELECT
      word.word,
      texts.title,
      texts.site,
      paragraph.text,
      paragraph.sequence,
      word.starting_position,
      word.length
    FROM
      public.paragraph
    INNER JOIN
      word ON
      word.fingerprint = paragraph.fingerprint
    INNER JOIN
      texts ON
      paragraph.texts_id = texts.id
    WHERE
      paragraph.fingerprint >
    """  <> "'" <> cursor <> "'" <>
    " AND " <>
    "(" <> Enum.join(clauses, " OR ") <> ")" <>
    " LIMIT 15;"
    {sql, Enum.sort(search_terms)}
  end

  defp make_ors(_title, []), do: []
  defp make_ors(title, matches) do
    clauses = for m <- matches, do: "word." <> title <> " = '" <> m <> "'"
    "(" <> Enum.join(clauses, " OR ") <> ")"
  end

  defp get_cursor() do
    # we are going to do a random offset for our searches so that each time you get
    # different results
    # a fingerprint is a hash of the form
    # 0deeb8fa1dbbee4c0dbe7f5e3c9183940139f26d22797ee8ab07c00557a4c2ff
    # the upper bound is therefore
    # ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    # we will generate a rnadom hash between:
    # 0000000000000000000000000000000000000000000000000000000000000000
    # and
    # efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
    # and then display 15 results with a hash higher than that
    {upper, ""} = Integer.parse("efffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff", 16)
    _randomcursor = String.downcase(Integer.to_string(Enum.random(0..upper), 16))
  end

end
