defmodule Stratego.Repo.Migrations.UpdateGameAddVisiblePieces do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add(:visible_pieces, {:array, {:array, :string}}, null: false, default: [])
    end
  end
end
