defmodule TekstaroWeb.PageController do
  use TekstaroWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def search(conn, %{"search_term" => s} = _params) do
    raw_paragraphs = Procezo.estigu_paragrafoj(s)
    paragraphs = for p <- raw_paragraphs, do: GenServer.call(Tekstaro.Text.Vortoj, {:process, p})
    words = get_words(paragraphs)
    sql = make_sql(words)
    response = Ecto.Adapters.SQL.query!(Tekstaro.Repo, sql)
    %Postgrex.Result{rows: rows} = response
    conn
    |> render("response.json", results: rows)
  end

  def redirect_frontpage(conn, _params) do
    conn
    |> redirect("/eo")
  end

  defp get_words(paragraphs) do
    terms = for p <- paragraphs do
      %Paragrafo{radikigoj: radikigoj} = p
        for %Radikigo{vorto: word, radikigo: root} <- radikigoj, do: {word, root}
    end
    terms2 = List.flatten(terms)
  end

  defp make_sql(terms) do
    # some words are consumed by their parts and don't have roots
    # eg `a` or `igo`
    clauses = for {word, root} <- terms do
        case root do
          "" -> "word.word = '" <> word <> "'"
          _  -> "word.root = '" <> root <> "'"
        end
    end
    """
    SELECT paragraph.text, word.starting_position, word.length FROM word
    INNER JOIN paragraph ON word.fingerprint = paragraph.fingerprint
    WHERE
    """ <> Enum.join(clauses, " OR ") <> "  LIMIT 15;"
  end

end
