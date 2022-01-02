defmodule StrategoWeb.JoinChangeset do
  defstruct [:username, :game_code]
  @types %{username: :string, game_code: :string}

  alias StrategoWeb.JoinChangeset
  import Ecto.Changeset

  def changeset(%JoinChangeset{} = join, attrs) do
    {join, @types}
    |> cast(attrs, Map.keys(@types))
    |> validate_required([:username, :game_code])
    |> validate_length(:username, min: 2, max: 25)
    |> validate_length(:game_code, min: 6, max: 6)
  end
end
