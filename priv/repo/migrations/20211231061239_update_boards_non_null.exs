defmodule Stratego.Repo.Migrations.UpdateBoardsNonNull do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      modify :turn, :integer, null: false
      modify :board, :map, null: false
      modify :number_players, :integer, null: false
      modify :winner, :integer
      modify :graveyard, {:array, :map}, null: false
      modify :eliminated_players, {:array, :integer}, null: false
      modify :game_code, :string, null: false

      modify :config, references(:game_configs, on_delete: :nothing),
        null: false,
        from: references(:game_configs, on_delete: :nothing)
    end
  end
end
