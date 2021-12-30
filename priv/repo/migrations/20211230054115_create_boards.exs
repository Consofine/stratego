defmodule Stratego.Repo.Migrations.CreateBoards do
  use Ecto.Migration

  def change do
    create table(:boards) do
      add :turn, :integer
      add :board, :map
      add :number_players, :integer
      add :winner, :integer
      add :graveyard, {:array, :map}
      add :eliminated_players, {:array, :integer}
      add :game_code, :string
      add :config, references(:game_configs, on_delete: :nothing)

      timestamps()
    end

    create index(:boards, [:config])
  end
end
