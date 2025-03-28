defmodule RealtimeSilakesWeb.NotificationChannel do
  use Phoenix.Channel

  def join("notifications:" <> role, _params, socket) do
    IO.puts("Kesini 2")
    send(self(), :after_join)
    {:ok, assign(socket, :role, role)}
  end

  def handle_info(:after_join, socket) do
    IO.puts("Kesini 3")
    push(socket, "joined", %{message: "You joined the notifications"})
    {:noreply, socket}
  end

  def handle_in("new_notification", %{"message" => message, "kepada" => kepada, "dari" => dari}, socket) do
    # role = socket.assigns[:role]
    if kepada == "all" do
      message = "#{dari} #{message}"
      broadcast!(socket, "new_notification", %{message: message})
    end
    if kepada == "admin" do
      message = "#{dari} #{message}"
      broadcast!(socket, "admin_notification", %{message: message})
      push(socket, "message_received", %{message: "Permintaan telah dikirim"})
    end
    if kepada == "administrasi" do
      message = "#{dari} #{message}"
      broadcast!(socket, "administrasi_notification", %{message: message})
      push(socket, "message_received", %{message: "Berhasil mengkonfirmasi hasil"})
    end


    {:noreply, socket}
  end
end
