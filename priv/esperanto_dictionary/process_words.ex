defmodule ProcessWords do

  defstruct radical:         "",
            is_verb:         false,
            is_transitive:   false,
            is_intransitive: false,
            etymology:        ""

#  def make_false_affixes() do
#
#    {:ok, [words]} = :file.consult('words3.csv')
#
#    dict_words = %{}
#    possibles = %{}

#    roots = parse_words(words, dict_words, possibles, [])
#    IO.inspect(roots)
#    IO.inspect(length(roots), label: "number of roots")

#  end

#  defp parse_words([], _dict_words, _possibles, fakes), do: fakes
#  defp parse_words([h | t], dict_words, possibles, fakes) do
#    word = to_string(h)
#    {r, _d, af} = Radikigoj.radikigu_vorto_TEST(word)
#    is_perfect = case String.reverse(word) do
#      "oda" <> _rest -> true
#      _              -> false
#    end
#    has_affix = case {length(af), is_perfect} do
#        {0, false} -> false
#        _          -> true
#      end
#    {nd, np, nf} = case has_affix do
#      false -> newdict = Map.put(dict_words, r, true)
#               newfakes = case Map.has_key?(possibles, r) do
#                 true  -> Map.get(possibles, r) ++ fakes
#                 false -> fakes
#               end
#          {newdict, possibles, newfakes}
#      true  -> case Map.has_key?(dict_words, r) do
#                true -> {dict_words, possibles, [word | fakes]}
#                false -> newp = Map.update(possibles, r, [word], &([word | &1]))
#                         {dict_words, newp, fakes}
#                end
#    end
#    parse_words(t, nd, np, nf)
#  end

  def run() do
    dict = %{}
    {:ok, [words]} = :file.consult('words3.csv')
    newdict = process_words(words, dict)
    IO.puts("words processed")

    {:ok, [etymology]} = :file.consult('etymology.csv')
    newdict2 = process_etymologies(etymology, newdict)
    IO.puts("eymologies processed")

    {:ok, [verbs]} = :file.consult('transitiveco.csv')
    newdict3 = process_verbs(verbs, newdict2)
    IO.puts("verb roots processed")

    {:ok, handle} = File.open("dictionary.sql", [:append])

    writefn = fn({k, v}) ->
      %ProcessWords{is_verb:         is_verb,
                    is_transitive:   is_transitive,
                    is_intransitive: is_intransitive,
                    etymology:       etymology} = v
      time = NaiveDateTime.to_string(NaiveDateTime.utc_now())
      sql = case etymology do
        "" ->
          "INSERT INTO dictionary " <>
          "(root, is_verb, is_transitive, is_intransitive, inserted_at, updated_at) " <>
          "VALUES" <>
          " ('" <>
          k                          <> "', "  <>
          to_string(is_verb)         <> ", "   <>
          to_string(is_transitive)   <> ", "   <>
          to_string(is_intransitive) <> ", '"  <>
          time                       <> "', '" <>
          time                       <> "')\n;"
        _ ->
          "INSERT INTO dictionary " <>
          "(root, is_verb, is_transitive, is_intransitive, etymology, inserted_at, updated_at) " <>
          "VALUES" <>
          " ('" <>
          k                          <> "', "  <>
          to_string(is_verb)         <> ", "   <>
          to_string(is_transitive)   <> ", "   <>
          to_string(is_intransitive) <> ", E'" <>
          escape(etymology)          <> "', '" <>
          time                       <> "', '" <>
          time                       <> "');\n"
      end
      :ok = IO.binwrite(handle, sql)
    end
    Enum.each(newdict3, writefn)
    :ok = File.close(handle)
    IO.puts("all sql written")
    :ok

  end

  defp escape(string), do: String.replace(string, "'", "''")

  defp process_verbs([], dict), do: dict
  defp process_verbs([{r, v} | t], dict) do
    [{radical, _details}] = get_roots(r)

    {updatefn, rec} = case v do
      'n' ->
        {fn(r) -> {r, %ProcessWords{r | is_verb:         true,
                                        is_intransitive: true}}
         end, %ProcessWords{radical:         radical,
                            is_verb:         true,
                            is_intransitive: true}}
      't' ->
        {fn(r) -> {r, %ProcessWords{r | is_verb:       true,
                                        is_transitive: true}}
        end, %ProcessWords{radical:       radical,
                           is_verb:       true,
                           is_transitive: true}}
      'tn' ->
        {fn(r) -> {r, %ProcessWords{r | is_verb:         true,
                                        is_transitive:   true,
                                        is_intransitive: true}}
        end, %ProcessWords{radical:         radical,
                           is_verb:         true,
                           is_transitive:   true,
                           is_intransitive: true}}
    end

    newdict = case Map.has_key?(dict, radical) do
      true  ->
        {_, newmap} = Map.get_and_update(dict, radical, updatefn)
        newmap
      false ->
        Map.put(dict, radical, rec)
    end
    process_verbs(t, newdict)
  end

  defp process_etymologies([], dict), do: dict
  defp process_etymologies([{r, e} | t], dict) do
    e2 = to_string(e)
    [{radical, _details}] = get_roots(r)

    newdict = case Map.has_key?(dict, radical) do
      true  ->
        {_, newmap} = Map.get_and_update(dict, radical, fn(record) -> {record, %ProcessWords{record | etymology: e2}} end)
        newmap
      false ->
        Map.put(dict, radical, %ProcessWords{radical: radical, etymology: e2})
    end
    process_etymologies(t, newdict)
  end

  defp process_words([], dict), do: dict
  defp process_words([h | t], dict) do
    roots = get_roots(h)
    newdict = Enum.reduce(roots, dict, fn({k, v}, d) -> Map.put(d, k, v) end)
    process_words(t, newdict)
  end

  defp get_roots(charlist) do
    text = to_string(charlist)
    raw_paragraphs = Procezo.estigu_paragrafoj(text)
    roots = for p <- raw_paragraphs do
      para =  GenServer.call(Tekstaro.Text.Vortoj, {:process, p})
      %Paragrafo{radikigoj: roots} = para
      for r <- roots do
        %Radikigo{radikigo: radical} = r
        {radical, %ProcessWords{radical: radical}}
      end
    end
    List.flatten(roots)
  end

end
