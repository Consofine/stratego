defmodule Stratego.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add(:status, :string, null: false)
      add(:uid, :string, null: false)
      add(:winner_id, references(:players, on_delete: :nothing))
      add(:board, {:array, {:array, :string}}, null: false)

      timestamps()
    end

    create(index(:games, [:winner_id]))
  end
end
