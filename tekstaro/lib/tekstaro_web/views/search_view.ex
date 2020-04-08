defmodule TekstaroWeb.SearchView do
  use TekstaroWeb, :view

  def render("browse.json", %{results: results}) do
    data = make_data(results)
    %{
      response: %{data: data}
    }
  end

  def render("parse.json", %{results: results, search_terms: search_terms}) do
    %{
      response: %{search_terms: search_terms, data: results}
    }
  end

  def render("search.json", %{results: results, search_terms: search_terms}) do
    data = make_data(results)
    %{
      response: %{search_terms: search_terms, data: data}
    }
  end

  defp make_data(results) do
    for r <- results do
      case r do
        [word, title, url, text, paragraph_sequence, start, length] ->
          element = %{title:              title,
                      url:                url,
                      text:               text,
                      paragraph_sequence: paragraph_sequence,
                      annotations:        [%{start: start, length: length}]}
          %{element: element, word: word}
      end
    end
  end

end
