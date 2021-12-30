defmodule Stratego.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players) do
      add :board, :map
      add :player_number, :integer
      add :color, :string
      add :player_secret, :string
      add :board_id, references(:boards, on_delete: :nothing)

      timestamps()
    end

    create index(:players, [:board_id])
  end
end
