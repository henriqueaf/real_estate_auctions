defmodule RealEstateAuctions.FileUtils do
  @moduledoc """
  Module to save files
  """

  alias RealEstateAuctions.{DateUtils}

  def log_error_in_file(error_message) do
    file_path = "#{tmp_folder_path()}/errors_log.txt"

    File.write!(file_path, "\n[#{DateUtils.current_date_time_string()}] => #{error_message}", [:append])
  end

  def save_file_in_tmp(file_name, file_content) do
    file_path = "#{tmp_folder_path()}/#{file_name}"

    File.write!(file_path, file_content)
  end

  def tmp_folder_path() do
    "#{File.cwd!()}/tmp"
  end
end
