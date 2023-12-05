defmodule Stratego.Forms.JoinGame do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :game_id, :string
    field :username, :string
  end

  def changeset(data, params) do
    data
    |> Ecto.Changeset.cast(params, [:game_id, :username])
    |> validate_required([:game_id, :username], message: "Required")
    |> validate_length(:game_id, is: 6, message: "Game ID should be 6 characters")
  end
end
