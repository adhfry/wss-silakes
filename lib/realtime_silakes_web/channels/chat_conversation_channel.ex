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
end
