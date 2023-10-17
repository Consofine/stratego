defmodule Stratego.Repo.Migrations.UpdatePlayersAddSecret do
  use Ecto.Migration

  def change do
    alter table(:players) do
      add :secret, :string, null: false
    end
  end
end
