defmodule Stratego.Player do
  use Ecto.Schema
  import Ecto.Changeset

  schema "players" do
    field(:username, :string)
    field(:color, Ecto.Enum, values: [:red, :white, :blue, :green])
    field(:status, Ecto.Enum, values: [:not_ready, :ready])
    field(:secret, :string)
    field(:index, :integer)

    belongs_to(:game, Stratego.Game)

    timestamps()
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:username, :color, :status, :secret, :index])
    |> validate_required([:username, :color, :status, :secret, :index])
  end
end
