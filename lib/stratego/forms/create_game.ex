defmodule Stratego.Forms.CreateGame do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :username, :string
  end

  def changeset(data, params) do
    data
    |> Ecto.Changeset.cast(params, [:username])
    |> validate_required([:username], message: "Username is required")
    |> validate_length(:username,
      min: 2,
      max: 12,
      message: "Username should be between 2 and 12 characters"
    )
  end
end
