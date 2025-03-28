defmodule RealtimeSilakes.Repo do
  use Ecto.Repo,
    otp_app: :realtime_silakes,
    adapter: Ecto.Adapters.MyXQL
end
