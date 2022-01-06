defmodule StrategoWeb.GameLive do
  use StrategoWeb, :live_view
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger
  alias Stratego.Game.{Player, Board, GameConfig}
  alias Stratego.Repo

  defp assign_current_player(socket) do
    try do
      current_player = Repo.get_by!(Player, player_secret: socket.assigns.player_secret)

      socket
      |> assign(current_player: current_player)
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

  defp assign_players(socket) do
    board = socket.assigns.board
    query = from p in Player, where: p.board_id == ^board.id
    players = Repo.all(query)

    socket
    |> assign(players: players)
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
     |> assign_board()
     |> assign_players()
     |> assign_current_player()}
  end

  def handle_event("leave_lobby", %{}, socket) do
    Logger.error("Leaving lobby!")
    player_secret = socket.assigns.player_secret

    try do
      player = Repo.get_by!(Player, player_secret: player_secret)
      board = Repo.get(Board, player.board_id)
      Repo.update(change(board, number_players: board.number_players + 1))

      player
      |> Repo.delete()
    rescue
      Ecto.NoResultsError ->
        {:noreply,
         push_redirect(socket,
           to: "/"
         )}
    end

    {:noreply,
     push_redirect(socket,
       to: "/"
     )}
  end
end
