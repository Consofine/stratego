defmodule Stratego.Repo.Migrations.UpdatePlayerAddIndex do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :index, :integer, null: false
    end
  end
end
