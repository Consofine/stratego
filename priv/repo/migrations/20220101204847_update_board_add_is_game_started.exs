defmodule Stratego.Repo.Migrations.UpdateBoardAddIsStarted do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :is_game_started, :boolean, default: false, null: false
    end
  end
end
