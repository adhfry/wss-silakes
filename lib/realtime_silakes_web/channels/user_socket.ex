defmodule RealtimeSilakesWeb.UserSocket do
  use Phoenix.Socket

  # Mendefinisikan channel "notifications:*" yang mengarah ke NotificationChannel
  channel "notifications:*", RealtimeSilakesWeb.NotificationChannel

  def connect(_params, socket, _connect_info) do
    IO.puts("Kesini")
    {:ok, socket}
  end

  def id(_socket), do: nil
end
