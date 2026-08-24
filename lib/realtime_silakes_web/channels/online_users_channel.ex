defmodule RealtimeSilakesWeb.OnlineUsersChannel do
  @moduledoc """
  Presence GLOBAL app-wide (BUKAN per-resource spt sirapat_workspace/
  acara_room) -- satu topic tunggal "online_users:app", dipakai widget
  header "siapa yang sedang online" (foto profil, permintaan user).
  Client join channel ini SEKALI per sesi (komponen navbar, mount sekali
  selama user login), BUKAN per-halaman.

  Reuse RealtimeSilakesWeb.Presence yang SUDAH ADA (dibangun generik utk
  SiRAPAT, dipakai ulang lagi di sini -- 3 modul sekarang share 1 Presence
  module yang sama, masing2 dgn topic berbeda).
  """
  use Phoenix.Channel
  alias RealtimeSilakesWeb.Presence

  def join("online_users:app", params, socket) do
    user_id = Map.get(params, "user_id")
    name = Map.get(params, "name", "Pengguna")
    photo_url = Map.get(params, "photo_url")

    if is_nil(user_id) do
      {:error, %{reason: "user_id wajib diisi"}}
    else
      send(self(), :after_join)

      socket =
        socket
        |> assign(:user_id, user_id)
        |> assign(:name, name)
        |> assign(:photo_url, photo_url)

      {:ok, socket}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        name: socket.assigns.name,
        photo_url: socket.assigns.photo_url,
        joined_at: System.system_time(:second)
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
