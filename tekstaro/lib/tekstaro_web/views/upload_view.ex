defmodule TekstaroWeb.UploadView do
  use TekstaroWeb, :view

  def render("upload.json", %{channel: channel}) do
      %{
        channel: channel
      }
  end

end
