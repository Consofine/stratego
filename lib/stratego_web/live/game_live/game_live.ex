defmodule StrategoWeb.GameLive do
  use StrategoWeb, :live_view
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias Stratego.Game.{Player, Board, GameConfig}
  alias Stratego.Repo

  defp assign_board(socket) do
    try do
      board = Repo.get_by!(Board, game_code: socket.assigns.game_code)

      socket
      |> assign(board: board)
    rescue
      Ecto.NoResultsError ->
        put_flash(
          socket,
          :error,
          "No game with this code exists. Did you use the wrong code?"
        )
        |> push_redirect(to: "/")
    end
  end

  def mount(
        %{"player_secret" => player_secret, "game_code" => game_code} = params,
        _session,
        socket
      ) do
    {:ok,
     socket
     |> assign(player_secret: player_secret)
     |> assign(game_code: game_code)
     |> assign_board()}
  end
end
