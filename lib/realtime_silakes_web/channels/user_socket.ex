defmodule RealtimeSilakesWeb.UserSocket do
  use Phoenix.Socket

  # Mendefinisikan channel "notifications:*" yang mengarah ke NotificationChannel
  channel "notifications:*", RealtimeSilakesWeb.NotificationChannel
  # Satu channel per rapat SiRAPAT (presence + live content + sinyal refetch
  # dokumentasi/tindak lanjut) -- lihat sirapat_workspace_channel.ex
  channel "sirapat_workspace:*", RealtimeSilakesWeb.SirapatWorkspaceChannel
  # Satu channel per acara (presence dua-stasiun + antrian pasien realtime)
  # -- lihat acara_room_channel.ex
  channel "acara_room:*", RealtimeSilakesWeb.AcaraRoomChannel
  # Presence GLOBAL app-wide "siapa yang sedang online" (widget header) --
  # lihat online_users_channel.ex
  channel "online_users:*", RealtimeSilakesWeb.OnlineUsersChannel

  def connect(_params, socket, _connect_info) do
    IO.puts("Kesini")
    {:ok, socket}
  end

  def id(_socket), do: nil
end
