defmodule Stratego.Repo.Migrations.UpdateGameAddActivePlayerId do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :active_player_id, references(:players, on_delete: :nothing)
    end
  end
end
