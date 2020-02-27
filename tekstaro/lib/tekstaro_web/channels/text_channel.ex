defmodule TekstaroWeb.TextChannel do
  use TekstaroWeb, :channel

  intercept ["status"]

  def join(name, _params, socket) do
  	IO.inspect(name, label: "got hash in channel")
  	reply = Tekstaro.Text.Text.get_status(name)
    {:ok, reply, socket}
  end
  
 def handle_out("status", msg, socket) do
	IO.inspect(msg, label: "being handled out")
    ret = push(socket, "status", msg)
    IO.inspect(ret, label: "push to socket returns")
    {:noreply, socket}
  end

end