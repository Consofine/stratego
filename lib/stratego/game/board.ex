defmodule Stratego.Game.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :board, :map
    field :eliminated_players, {:array, :integer}
    field :game_code, :string
    field :graveyard, {:array, :map}
    field :number_players, :integer
    field :turn, :integer
    field :winner, :integer
    field :config, :id

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:turn, :board, :number_players, :winner, :graveyard, :eliminated_players, :game_code])
    |> validate_required([:turn, :board, :number_players, :winner, :graveyard, :eliminated_players, :game_code])
  end
end
