defmodule Stratego.Repo.Migrations.UpdatePlayersDropActiveAndLeaderAddStatus do
  use Ecto.Migration

  def change do
    alter table(:players) do
      remove :is_active
      remove :is_leader
      add :status, :string, null: false
    end
  end
end
