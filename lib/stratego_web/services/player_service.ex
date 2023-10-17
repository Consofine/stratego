defmodule StrategoWeb.Services.PlayerService do
  alias Stratego.{Repo}
  require Logger

  def add_to_game(username, color, game) do
    secret = Ecto.UUID.generate()

    player =
      Ecto.build_assoc(game, :players, %{
        username: username,
        color: color,
        secret: secret,
        status: :not_ready,
        index: length(game.players)
      })

    {:ok,
     player
     |> Repo.insert!()}
  end
end
