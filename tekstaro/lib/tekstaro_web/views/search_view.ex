defmodule TekstaroWeb.SearchView do
  use TekstaroWeb, :view

  def render("parse.json", %{results: results, search_terms: search_terms}) do
    %{
      response: %{search_terms: search_terms, data: results}
    }
  end

  def render("search.json", %{results: results, search_terms: search_terms}) do
    data = for [text, start, length] <- results do
      _element = %{text: text, annotations: [%{start: start, length: length}]}
    end
    %{
      response: %{search_terms: search_terms, data: data}
    }
  end

end
