defmodule Stratego.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field(:status, Ecto.Enum, values: [:in_lobby, :active, :completed])
    field(:uid, :string)
    field(:winner_id, :id)
    field(:board, {:array, {:array, :string}})
    field(:active_player_id, :id)

    has_many(:players, Stratego.Player)
    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:status, :uid, :board, :active_player_id, :winner_id])
    |> validate_required([:status, :uid, :board])
    |> validate_length(:uid, is: 6)
  end
end
