defmodule Tekstaro.DynamicTextSupervisor do
  use Supervisor

  @registry :text_registry

  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    children = [
      {Tekstaro.Text.TextSupervisor, []},
      {Tekstaro.Text.Vortoj,         []},
      {Registry,                     [keys: :unique, name: @registry]}
    ]

    # :one_to_one strategy indicates only the crashed child will be restarted, without affecting the rest of children.
    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.init(children, opts)
  end


end
