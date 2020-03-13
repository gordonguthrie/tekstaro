defmodule TekstaroWeb.TextChannel do
  use TekstaroWeb, :channel

  intercept ["status"]

  def join(name, _params, socket) do
    reply = Tekstaro.Text.Text.get_status(name)
    {:ok, reply, socket}
  end

  def handle_out("status", msg, socket) do
    :ok = push(socket, "status", msg)
    {:noreply, socket}
  end
end
