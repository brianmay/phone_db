defmodule PhoneDbWeb.ContactView do
  use PhoneDbWeb, :view
  require PhoneDb.Forms
  import PhoneDb.Forms

  def format_timestamp(nil) do
    nil
  end

  def format_timestamp(timestamp) do
    timestamp
    |> shift_zone!("Australia/Melbourne")
    |> Calendar.Strftime.strftime!("%d/%m/%Y %H:%M")
  end

  defp shift_zone!(nil, _time_zone) do
    nil
  end

  defp shift_zone!(timestamp, time_zone) do
    timestamp
    |> Calendar.DateTime.shift_zone!(time_zone)
  end
end
