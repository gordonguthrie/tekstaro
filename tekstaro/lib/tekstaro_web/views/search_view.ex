defmodule TekstaroWeb.SearchView do
  use TekstaroWeb, :view

  def render("parse.json", %{results: results, search_terms: search_terms}) do
    %{
      response: %{search_terms: search_terms, data: results}
    }
  end

  def render("search.json", %{results: results, search_terms: search_terms}) do
    data = for [title, url, text, paragraph_sequence, start, length] <- results do
      _element = %{title:              title,
                   url:                url,
                   text:               text,
                   paragraph_sequence: paragraph_sequence,
                   annotations:        [%{start: start, length: length}]}
    end
    %{
      response: %{search_terms: search_terms, data: data}
    }
  end

end
