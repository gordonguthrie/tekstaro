defmodule TekstaroWeb.PageView do
  use TekstaroWeb, :view

  def render("response.json", %{results: results}) do
    data = for [text, start, length] <- results do
       %{text: text, annotations: [%{start: start, length: length}]}
     end
    %{
      response: data
    }
  end

end
