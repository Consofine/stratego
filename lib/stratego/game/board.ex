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
    field :is_game_started, :boolean, default: false
    field :config, :id

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [
      :turn,
      :board,
      :number_players,
      :winner,
      :graveyard,
      :eliminated_players,
      :game_code,
      :is_game_started,
      :config
    ])
    |> validate_required([
      :turn,
      :board,
      :number_players,
      :winner,
      :graveyard,
      :game_code,
      :eliminated_players,
      :is_game_started
    ])
    |> validate_length(:game_code, min: 8, max: 8)
  end
end
