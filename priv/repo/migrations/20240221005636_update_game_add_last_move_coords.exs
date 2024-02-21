defmodule Stratego.Repo.Migrations.UpdateGameAddLastMoveCoords do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :last_move_coords, :string
    end
  end
end
