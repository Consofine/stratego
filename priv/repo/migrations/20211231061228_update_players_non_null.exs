defmodule Stratego.Repo.Migrations.UpdatePlayersNonNull do
  use Ecto.Migration

  def change do
    alter table(:players) do
      modify :board, :map, null: false
      modify :player_number, :integer, null: false
      modify :color, :string, null: false, null: false
      modify :player_secret, :string, null: false
      add :username, :string, null: false
    end

    create index(:players, [:player_secret])
  end
end
