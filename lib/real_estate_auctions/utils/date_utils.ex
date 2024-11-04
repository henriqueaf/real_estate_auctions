defmodule RealEstateAuctions.DateUtils do
  @moduledoc """
  Module for date purposes
  """

  def current_date_time() do
    DateTime.now!("America/Fortaleza")
  end

  def current_date_time_string() do
    current_date_time()
    |> Calendar.strftime("%d%m%Y_%H%M%S%z")
  end
end
