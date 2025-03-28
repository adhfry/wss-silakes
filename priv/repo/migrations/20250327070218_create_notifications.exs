defmodule RealtimeSilakes.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :message, :string
      add :user_id, :integer  # Menyimpan ID user yang menerima notifikasi
      add :status, :string  # Menyimpan status (misalnya: "pending", "approved", "rejected")
      add :role, :string  # Menyimpan role user (admin/pegawai)
      timestamps()
    end

    create index(:notifications, [:user_id])
  end
end
