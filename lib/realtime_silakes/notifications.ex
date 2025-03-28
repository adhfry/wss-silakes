defmodule RealtimeSilakes.Notifications do
  use Ecto.Schema
  import Ecto.Changeset

  schema "notifications" do
    field :message, :string
    field :user_id, :integer
    field :status, :string
    field :role, :string
    timestamps()
  end

  def changeset(notification, attrs) do
    notification
    |> cast(attrs, [:message, :status, :role, :user_id])
    |> validate_required([:message, :status, :role, :user_id])
  end
end
