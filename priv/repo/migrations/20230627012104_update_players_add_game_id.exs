defmodule Stratego.Repo.Migrations.UpdatePlayersAddGameId do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add(:game_id, references(:games, on_delete: :delete_all))
    end
  end
end
