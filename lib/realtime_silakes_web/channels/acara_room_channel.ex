defmodule RealtimeSilakesWeb.AcaraRoomChannel do
  @moduledoc """
  Satu channel per acara: "acara_room:<acara_id>". Dipakai DUA halaman
  sekaligus (Input Pemeriksaan Acara & Input Hasil Pemeriksaan Acara) --
  keduanya join topic YANG SAMA dgn `station` berbeda ("pemeriksaan" atau
  "hasil") di meta Presence, supaya tiap halaman bisa lihat siapa standby
  di STASIUN LAIN juga, bukan cuma stasiunnya sendiri.

  Reuse RealtimeSilakesWeb.Presence yang SUDAH ADA (dibangun generik utk
  SiRAPAT, tidak spesifik-modul) -- tidak perlu Presence module baru.

  "new_patient_queue"/"hasil_updated" dipicu FE (loket setelah submit
  pendaftaran, ATLM setelah simpan hasil) -- broadcast_from! mendorong
  payload LANGSUNG ke klien lain yg standby di topic ini, BUKAN pola
  ping-lalu-refetch Firebase yg dipakai CFD/OPD saat ini.
  """
  use Phoenix.Channel
  alias RealtimeSilakesWeb.Presence

  def join("acara_room:" <> acara_id, params, socket) do
    user_id = Map.get(params, "user_id")
    name = Map.get(params, "name", "Pengguna")
    photo_url = Map.get(params, "photo_url")
    station = Map.get(params, "station", "pemeriksaan")

    if is_nil(user_id) do
      {:error, %{reason: "user_id wajib diisi"}}
    else
      send(self(), :after_join)

      socket =
        socket
        |> assign(:acara_id, acara_id)
        |> assign(:user_id, user_id)
        |> assign(:name, name)
        |> assign(:photo_url, photo_url)
        |> assign(:station, station)

      {:ok, socket}
    end
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        name: socket.assigns.name,
        photo_url: socket.assigns.photo_url,
        station: socket.assigns.station,
        joined_at: System.system_time(:second)
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  def handle_in("new_patient_queue", payload, socket) do
    broadcast_from!(socket, "new_patient_queue", Map.put(payload, "user_id", socket.assigns.user_id))
    {:noreply, socket}
  end

  def handle_in("hasil_updated", payload, socket) do
    broadcast_from!(socket, "hasil_updated", Map.put(payload, "user_id", socket.assigns.user_id))
    {:noreply, socket}
  end
end
