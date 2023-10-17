defmodule StrategoWeb.PlayLive do
  alias StrategoWeb.Services.UtilsService
  use StrategoWeb, :live_view

  alias StrategoWeb.Services.{BoardService, GameService}
  alias Stratego.{Game, Repo, Player}
  require Logger
  import Ecto.Query

  def mount(%{"uid" => uid}, %{"secret" => secret}, socket) do
    game = from(g in Game, where: g.uid == ^uid, select: g, preload: [:players]) |> Repo.one()

    Logger.debug("Game players: #{inspect(game.players)}")

    self =
      game.players
      |> Enum.find(fn player ->
        player.secret == secret
      end)

    Logger.debug("Current player: #{inspect(self)}")

    cond do
      game == nil ->
        params = %{error: :not_found}
        {:ok, push_navigate(socket, to: ~p(/error?#{params}))}

      self == nil ->
        params = %{error: :invalid_session}
        {:ok, push_navigate(socket, to: ~p(/error?#{params}))}

      true ->
        players =
          game.players
          |> Enum.map(fn player_struct ->
            Map.from_struct(player_struct)
          end)

        {:ok,
         socket
         |> assign(:game, game)
         |> assign(:self, Map.from_struct(self))
         |> assign(:players, players)
         |> assign(:selected, nil)}
    end
  end

  def mount(_params, _session, socket) do
    params = %{error: :no_session}
    {:ok, socket |> push_navigate(to: ~p(/error?#{params}))}
  end

  def handle_event("ready-up", _params, %{assigns: %{self: self, game: game}} = socket) do
    # player = from(p in Player, where: p.secret == ^secret, select: p) |> Repo.one!()
    # {:ok, socket |> assign(:self)}
    self = struct!(Player, self)
    player = Player.changeset(self, %{status: :ready}) |> Repo.update!()
    game = from(g in Game, where: g.id == ^game.id, select: g, preload: [:players]) |> Repo.one!()

    if game.players
       |> Enum.all?(fn player ->
         player.status == :ready
       end) do
      first_player =
        game.players
        |> Enum.find(fn player ->
          player.index == 0
        end)

      game =
        Game.changeset(game, %{status: :active, active_player_id: first_player.id})
        |> Repo.update!()

      {:noreply, socket |> assign(:self, Map.from_struct(player)) |> assign(:game, game)}
    else
      {:noreply, socket |> assign(:self, Map.from_struct(player))}
    end
  end

  @doc """
  Select piece when game is in lobby and there's already a piece selected.
  Given valid arguments, this will swap the user's pieces.
  """
  def handle_event(
        "select-piece-lobby",
        %{"coords" => coords} = _params,
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :in_lobby and not is_nil(selected) do
    Logger.critical("Self id: #{Map.get(self, :id)}")
    own_color = Map.get(self, :color)

    with {:ok, {x, y}} <- UtilsService.parse_coordinates_string(coords) do
      case maybe_swap_pieces(game.board, own_color, selected, {x, y}) do
        {:ok, board} ->
          game = Game.changeset(game, %{board: board}) |> Repo.update!()
          {:noreply, socket |> assign(:game, game) |> assign(:selected, nil)}

        {:error} ->
          {:noreply, socket |> assign(:selected, nil)}
      end
    else
      _ -> {:noreply, socket |> assign(:selected, nil)}
    end
  end

  @doc """
  Select piece when game is in lobby and there's no selected piece yet.
  Given valid arguments, this will update state to show that this cell is "selected"
  """
  def handle_event(
        "select-piece-lobby",
        %{"coords" => coords},
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :in_lobby and is_nil(selected) do
    Logger.critical("Self id: #{Map.get(self, :id)}")
    own_color = Map.get(self, :color)

    with {:ok, {x, y}} <- UtilsService.parse_coordinates_string(coords) do
      case maybe_select_cell(game.board, own_color, {x, y}) do
        {:ok, selected} -> {:noreply, socket |> assign(:selected, selected)}
        {:error} -> {:noreply, socket}
      end
    else
      _ -> {:noreply, socket}
    end
  end

  @doc """
  Select piece when game is active and there's a currently selected piece.
  Attempts to make move, given valid arguments, and updates board state if successful.
  """
  def handle_event(
        "select-piece-active",
        %{"coords" => coords} = _params,
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :active and not is_nil(selected) do
    Logger.critical("Self id: #{Map.get(self, :id)}")
    own_color = Map.get(self, :color)

    with {:ok, {x, y}} <- UtilsService.parse_coordinates_string(coords) do
      Logger.debug("NOT IN LOBBY")
      Logger.critical("SELECTED")

      case GameService.maybe_make_move(game.board, own_color, selected, {x, y}) do
        {:ok, board} ->
          game = GameService.end_turn(game, board)
          {:noreply, socket |> assign(:game, game) |> assign(:selected, nil)}

        {:error} ->
          {:noreply, socket |> assign(:selected, nil)}
      end
    else
      _ -> {:noreply, socket}
    end
  end

  @doc """
  Select piece when game is active and selected is nil.
  Updates state to show that the given cell is selected, assuming
  valid arguments.
  """
  def handle_event(
        "select-piece-active",
        %{"coords" => coords},
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :active and is_nil(selected) do
    Logger.critical("NOT SELECTED")
    own_color = Map.get(self, :color)

    with {:ok, {x, y}} <- UtilsService.parse_coordinates_string(coords) do
      case maybe_select_cell(game.board, own_color, {x, y}) do
        {:ok, selected} -> {:noreply, socket |> assign(:selected, selected)}
        {:error} -> {:noreply, socket}
      end
    else
      _ -> {:noreply, socket |> assign(:selected, nil)}
    end
  end

  def is_own_piece(board, own_color, x, y) do
    BoardService.is_own_piece(board, own_color, {x, y})
  end

  # def maybe_move_piece(board, own_color, first_coords, second_coords) do
  # GameService.maybe_make_move(board, own_color, first_coords, second_coords)
  # end

  def maybe_swap_pieces(
        board,
        own_color,
        {x, y} = first_coords,
        {a, b} = second_coords
      ) do
    with true <- first_coords != second_coords,
         true <- is_own_piece(board, own_color, x, y),
         true <- is_own_piece(board, own_color, a, b) do
      {:ok, BoardService.swap!(board, first_coords, second_coords)}
    else
      _ -> {:error}
    end
  end

  def maybe_select_cell(board, own_color, {x, y}) do
    if is_own_piece(board, own_color, x, y) do
      {:ok, {x, y}}
    else
      {:error}
    end
  end
end
