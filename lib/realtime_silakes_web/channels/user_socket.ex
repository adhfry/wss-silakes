defmodule RealtimeSilakesWeb.UserSocket do
  use Phoenix.Socket

  # Mendefinisikan channel "notifications:*" yang mengarah ke NotificationChannel
  channel "notifications:*", RealtimeSilakesWeb.NotificationChannel
  # Satu channel per rapat SiRAPAT (presence + live content + sinyal refetch
  # dokumentasi/tindak lanjut) -- lihat sirapat_workspace_channel.ex
  channel "sirapat_workspace:*", RealtimeSilakesWeb.SirapatWorkspaceChannel

  def connect(_params, socket, _connect_info) do
    IO.puts("Kesini")
    {:ok, socket}
  end

  def id(_socket), do: nil
end
