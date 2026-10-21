defmodule RealtimeSilakesWeb.ChatConversationChannel do
  @moduledoc """
  Satu channel per percakapan chat: "chat_conversation:<conversation_id>".
  Client join channel ini utk SETIAP percakapan yang sedang dibuka di
  widget chat (bisa lebih dari satu kalau user buka beberapa tab
  percakapan sekaligus di widget).

  "new_message" -- dipicu FE SETELAH POST /chat/conversations/{id}/messages
  ke Laravel sukses (sumber kebenaran TETAP database via HTTP API, socket
  cuma relay realtime ke peserta lain yg sedang standby di percakapan
  ini) -- broadcast_from! mengecualikan pengirim sendiri (dia sudah lihat
  pesannya sendiri muncul dari respons HTTP langsung, tidak perlu
  "gema" dari socket).

  "typing"/"stop_typing" -- indikator mengetik (permintaan user), MURNI
  ephemeral (tidak pernah disimpan ke database sama sekali) -- relay apa
  adanya, sama persis pola "new_message".

  "read" -- dipicu FE SETELAH POST /chat/conversations/{id}/read ke
  Laravel sukses, supaya centang 2 (dibaca) di sisi pengirim update
  realtime tanpa perlu refresh/poll -- sumber kebenaran TETAP
  conversation_participants.last_read_at di database, ini cuma notifikasi
  tambahan.

  TIDAK ada validasi keanggotaan percakapan di level channel ini (BEDA dari
  sirapat_workspace/acara_room yang juga tidak validasi ketat) -- otorisasi
  SUNGGUHAN (siapa boleh baca/kirim pesan percakapan ini) tetap di Laravel
  (ChatController::assertParticipant()), channel Phoenix murni jalur
  notifikasi tambahan, bukan lapis keamanan.
  """
  use Phoenix.Channel

  def join("chat_conversation:" <> conversation_id, params, socket) do
    user_id = Map.get(params, "user_id")

    if is_nil(user_id) do
      {:error, %{reason: "user_id wajib diisi"}}
    else
      socket =
        socket
        |> assign(:conversation_id, conversation_id)
        |> assign(:user_id, user_id)

      {:ok, socket}
    end
  end

  def handle_in("new_message", payload, socket) do
    broadcast_from!(socket, "new_message", Map.put(payload, "from_user_id", socket.assigns.user_id))
    {:noreply, socket}
  end

  def handle_in("typing", payload, socket) do
    broadcast_from!(socket, "typing", Map.put(payload, "from_user_id", socket.assigns.user_id))
    {:noreply, socket}
  end

  def handle_in("stop_typing", payload, socket) do
    broadcast_from!(socket, "stop_typing", Map.put(payload, "from_user_id", socket.assigns.user_id))
    {:noreply, socket}
  end

  def handle_in("read", payload, socket) do
    broadcast_from!(socket, "read", Map.put(payload, "from_user_id", socket.assigns.user_id))
    {:noreply, socket}
  end

  # "message_updated" -- dipicu FE/MATRIX SETELAH DELETE /chat/messages/{id}
  # (scope=all) ke Laravel sukses, supaya bubble di peserta lain langsung
  # berubah jadi "Pesan ini telah dihapus". Payload = pesan hasil respons
  # Laravel; sumber kebenaran tetap database.
  def handle_in("message_updated", payload, socket) do
    broadcast_from!(socket, "message_updated", Map.put(payload, "from_user_id", socket.assigns.user_id))
    {:noreply, socket}
  end
end
