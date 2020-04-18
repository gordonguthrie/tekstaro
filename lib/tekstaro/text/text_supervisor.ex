defmodule Tekstaro.Text.TextSupervisor do
  use DynamicSupervisor
  alias Tekstaro.Text.Text

  def start_link(_arg),
    do: DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)

  def init(_arg),
    do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_child(child_name) do
    DynamicSupervisor.start_child(
      __MODULE__,
      %{id: Text, start: {Text, :start_link, [child_name]}, restart: :transient}
    )
  end
end
