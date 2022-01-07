defmodule Stratego.Repo.Migrations.UpdatePlayerAddIsHost do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :is_host, :boolean, default: false, null: false
    end
  end
end
