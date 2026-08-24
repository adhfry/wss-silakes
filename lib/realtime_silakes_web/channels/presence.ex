defmodule RealtimeSilakesWeb.Presence do
  @moduledoc """
  Phoenix.Presence untuk fitur SiRAPAT Workspace: melacak siapa saja user yang
  sedang standby di halaman /sirapat/meetings/:id/workspace (foto profil +
  animasi muncul/hilang di FE). Pakai Phoenix.PubSub yang SUDAH ada
  (RealtimeSilakes.PubSub, lihat application.ex), BUKAN infra baru --
  Presence otomatis broadcast "presence_diff" ke semua client di topic yang
  sama tiap kali ada yang join/leave (termasuk saat koneksi socket putus
  paksa, mis. tab ditutup/koneksi hilang -- BUKAN cuma leave eksplisit),
  jadi FE tidak perlu polling utk tahu siapa yang masih standby.
  """
  use Phoenix.Presence,
    otp_app: :realtime_silakes,
    pubsub_server: RealtimeSilakes.PubSub
end
