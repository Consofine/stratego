defmodule StrategoWeb.PlayLive do
  alias StrategoWeb.Services.UtilsService
  use StrategoWeb, :live_view

  alias StrategoWeb.Services.{BoardService, GameService}
  alias Stratego.{Game, Repo, Player}
  import Ecto.Query

  def mount(%{"uid" => uid}, %{"secret" => secret}, socket) do
    game = from(g in Game, where: g.uid == ^uid, select: g, preload: [:players]) |> Repo.one()

    self =
      game.players
      |> Enum.find(fn player ->
        player.secret == secret
      end)

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

        StrategoWeb.Endpoint.subscribe("game/#{uid}")

        StrategoWeb.Endpoint.broadcast_from(self(), "game/#{game.uid}", "player_joined", %{
          game: game
        })

        {:ok,
         socket
         |> assign(:self, Map.from_struct(self))
         |> assign(:game, game)
         |> assign_game(game)
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

    if Enum.all?(game.players, fn player ->
         player.status == :ready
       end) && length(game.players) > 1 do
      first_player =
        game.players
        |> Enum.find(fn player ->
          player.index == 0
        end)

      game =
        Game.changeset(game, %{status: :active, active_player_id: first_player.id})
        |> Repo.update!()
        |> Repo.preload([:players])

      StrategoWeb.Endpoint.broadcast_from(self(), "game/#{game.uid}", "readied_up", %{
        game: game
      })

      {:noreply, socket |> assign(:self, Map.from_struct(player)) |> assign_game(game)}
    else
      StrategoWeb.Endpoint.broadcast_from(self(), "game/#{game.uid}", "readied_up", %{
        game: game
      })

      {:noreply, socket |> assign(:self, Map.from_struct(player)) |> assign_game(game)}
    end
  end

  def handle_event(
        "select-piece-lobby",
        %{"coords" => coords} = _params,
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :in_lobby and not is_nil(selected) do
    own_color = Map.get(self, :color)

    with {:ok, {x, y}} <- UtilsService.parse_coordinates_string(coords),
         {:ok, board} <- maybe_swap_pieces(game.board, own_color, selected, {x, y}) do
      game = Game.changeset(game, %{board: board}) |> Repo.update!()

      StrategoWeb.Endpoint.broadcast_from(self(), "game/#{game.uid}", "made_move", %{
        game: game
      })

      {:noreply, socket |> assign_game(game) |> assign(:selected, nil)}
    else
      _ -> {:noreply, socket |> assign(:selected, nil)}
    end
  end

  def handle_event(
        "select-piece-lobby",
        %{"coords" => coords},
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :in_lobby and is_nil(selected) do
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

  def handle_event(
        "select-piece-active",
        %{"coords" => coords} = _params,
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :active and not is_nil(selected) do
    own_color = Map.get(self, :color)

    with {:ok, {x, y}} <- UtilsService.parse_coordinates_string(coords) do
      case GameService.maybe_make_move(game, own_color, selected, {x, y}) do
        {:ok, new_board, visible_pieces} ->
          game = GameService.end_turn(game, new_board, visible_pieces)

          StrategoWeb.Endpoint.broadcast_from(self(), "game/#{game.uid}", "made_move", %{
            game: game
          })

          {:noreply, socket |> assign_game(game) |> assign(:selected, nil)}

        {:error} ->
          {:noreply, socket |> assign(:selected, nil)}
      end
    else
      _ ->
        {:noreply, socket}
    end
  end

  def handle_event(
        "select-piece-active",
        %{"coords" => coords},
        %{assigns: %{selected: selected, game: game, self: self}} = socket
      )
      when game.status == :active and is_nil(selected) do
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

  def handle_info(%{payload: %{game: game}}, socket) do
    {:noreply, socket |> assign_game(game)}
  end

  def handle_info(%{event: "player_joined", payload: %{game: game}}, socket) do
    {:noreply, socket |> assign_game(game)}
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

  def assign_game(%{assigns: %{self: self}} = socket, game) do
    socket
    |> assign(:clean_game, GameService.clean_game(game, self))
    |> assign(:game, game)
  end
end
