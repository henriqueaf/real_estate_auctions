defmodule RealEstateAuctions.Caixa.FetchAuctionsScheduler do
  @moduledoc """
  Scheduler to start fetching Caixa auctions periodically
  """

  use GenServer
  alias RealEstateAuctions.Caixa.{Service}

  # ================== CLIENT SIDE ==================
  def start() do
    # This will call the init() method with nil as param
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  # ================== SERVER SIDE ==================
  @impl GenServer
  def init(_) do
    schedule_process_message(true)
    {:ok, []}
  end

  @impl GenServer
  def handle_info(:fetch_auctions, _state) do
    IO.puts "=============== Start fetching auctions =================="

    Service.fetch_auctions()

    schedule_process_message(false)

    {:noreply, []}
  end

  defp schedule_process_message(execute_immediately?) do
    execute_in = if execute_immediately?, do: 0, else: 1000 * 60 * 60 * 24 # 24 hours in milliseconds

    Process.send_after(__MODULE__, :fetch_auctions, execute_in)
  end
end
