defmodule RealEstateAuctions.FetchAuctionsScheduler do
  @moduledoc """
  Scheduler to start fetching auctions periodically
  """

  use GenServer
  alias RealEstateAuctions.AuctionsServices.{CaixaService}

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

    CaixaService.fetch_real_estate_auctions()

    schedule_process_message(false)

    {:noreply, []}
  end

  defp schedule_process_message(execute_immediately?) do
    execute_in = if execute_immediately?, do: 0, else: 1000 * 60 * 60 * 5 # 5 hours in milliseconds

    Process.send_after(__MODULE__, :fetch_auctions, execute_in)
  end
end
