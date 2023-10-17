defmodule Stratego.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add(:is_active, :boolean, default: false, null: false)
      add(:is_leader, :boolean, default: false, null: false)
      add(:username, :string, null: false)
      add(:color, :string, null: false)

      timestamps()
    end
  end
end
