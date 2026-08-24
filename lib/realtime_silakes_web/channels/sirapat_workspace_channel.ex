defmodule RealtimeSilakesWeb.SirapatWorkspaceChannel do
  @moduledoc """
  Satu channel per rapat SiRAPAT: "sirapat_workspace:<meeting_id>". Gabungan
  3 hal, SEMUA discope ke topic per-rapat ini (bukan broadcast global) supaya
  tiap ruang kerja rapat terisolasi dari rapat lain:

  1. PRESENCE -- siapa yang lagi buka halaman workspace rapat ini (foto,
     nama), otomatis update saat join/leave/koneksi putus (lihat presence.ex).
  2. "content_update" -- broadcast isi draft risalah ke peserta lain SEGERA
     saat diketik (BUKAN operational-transform/CRDT konflik-bebas penuh spt
     Google Docs -- ini cuma "siaran versi terbaru", broadcast_from!
     mengecualikan pengirim sendiri; kalau 2 admin mengetik PERSIS bersamaan
     di baris yang sama, yang datang belakangan menang -- cukup utk kasus
     nyata SiRAPAT: beberapa admin bergantian/saling menambahkan, bukan
     mengetik di karakter yang sama pada saat yang sama).
  3. "data_changed" -- sinyal RINGAN "dokumentasi/tindak lanjut berubah,
     tolong refetch" -- BUKAN data penuh lewat socket (data asli tetap dari
     Laravel API yang py otorisasi & validasi lengkap; socket cuma pemicu
     supaya client lain tidak perlu polling manual).
  """
  use Phoenix.Channel
  alias RealtimeSilakesWeb.Presence

  def join("sirapat_workspace:" <> meeting_id, params, socket) do
    user_id = Map.get(params, "user_id")
    name = Map.get(params, "name", "Pengguna")
    photo_url = Map.get(params, "photo_url")

    if is_nil(user_id) do
      {:error, %{reason: "user_id wajib diisi"}}
    else
      send(self(), :after_join)

      socket =
        socket
        |> assign(:meeting_id, meeting_id)
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

  def handle_in("content_update", %{"content" => content}, socket) do
    broadcast_from!(socket, "content_update", %{
      content: content,
      user_id: socket.assigns.user_id
    })

    {:noreply, socket}
  end

  def handle_in("data_changed", %{"scope" => scope}, socket) do
    broadcast_from!(socket, "data_changed", %{
      scope: scope,
      user_id: socket.assigns.user_id
    })

    {:noreply, socket}
  end
end
