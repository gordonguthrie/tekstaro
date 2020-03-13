defmodule Tekstaro.Text.Vortoj do
  use GenServer
  alias Tekstaro.Text.Vortoj, as: State

  defstruct afiksa_vortaro: [],
            vortaro: []

  #
  # Gen Server callbacks
  #

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    afiksa_vortaro = Vorto.akiru_malvera_afikso_vortaro()
    vortaro = Vorto.akiru_vortaro()
    {:ok, %State{afiksa_vortaro: afiksa_vortaro, vortaro: vortaro}}
  end

  @impl true
  def handle_call({:process, %Paragrafo{radikigoj: tokenoj} = p}, _from, state) do
    %State{afiksa_vortaro: afiksa_vortaro, vortaro: vortaro} = state

    {_, _, _, tj} =
      Enum.reduce(tokenoj, {0, vortaro, afiksa_vortaro, []}, &Procezo.procezu_vorto/2)

    reply = %Paragrafo{p | radikigoj: tj}
    {:reply, reply, state}
  end
end
