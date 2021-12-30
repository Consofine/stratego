defmodule Stratego.Repo.Migrations.CreateGameConfigs do
  use Ecto.Migration

  def change do
    create table(:game_configs) do
      add :attack_and_move, :boolean, default: true, null: false
      add :move_to_defeated, :boolean, default: false, null: false
      add :attacker_advantage, :boolean, default: false, null: false
      add :defender_reveal, :boolean, default: true, null: false

      timestamps()
    end
  end
end
