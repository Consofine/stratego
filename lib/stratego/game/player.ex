defmodule Stratego.Game.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field :board, :map
    field :color, Ecto.Enum, values: [:blue, :red, :white, :black]
    field :player_number, :integer
    field :player_secret, :string
    field :username, :string
    field :board_id, :id

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:board, :player_number, :color, :player_secret, :username])
    |> validate_required([:board, :player_number, :color, :player_secret, :username])
    |> validate_length(:username, min: 2, max: 25)
  end
end
