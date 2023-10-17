defmodule StrategoWeb.Services.GameService do
  alias Stratego.Player
  alias Stratego.{Game, Repo, Constants}
  alias StrategoWeb.Services.{RandomService, BoardService}
  import Ecto.Query
  require Logger

  @db_colors Constants.db_colors()

  def create_game() do
    uid = RandomService.generate_uid()
    {:ok, board} = BoardService.set_up()
    game_attrs = %{status: :in_lobby, uid: uid, board: board}
    game_cs = Game.changeset(%Game{}, game_attrs)

    with true <- game_cs.valid?,
         {:ok, game} <- game_cs |> Repo.insert() do
      {:ok, game |> Repo.preload(:players)}
    else
      _ ->
        {:error}
    end
  end

  def join_game(uid, player) do
    game = from(g in Game, where: g.uid == ^uid, select: g, preload: [:players]) |> Repo.one()

    case game do
      nil ->
        Logger.critical("No game!")
        {:error, "Game not found. Check the game code and try again."}

      _ ->
        Logger.critical(inspect(game))

        player_number = length(game.players) + 1

        if player_number > Constants.max_players() do
          {:error, "This lobby is full"}
        else
          board = BoardService.add_starting_pieces(game.board, player_number - 1)
          game_attrs = %{board: board}
          game_cs = Game.changeset(game, game_attrs)
          index = player_number - 1

          game =
            game_cs
            |> Repo.update!()

          player =
            Ecto.build_assoc(
              game,
              :players,
              Map.merge(player, %{
                color: Enum.at(@db_colors, index),
                status: :not_ready,
                index: index
              })
            )

          player |> Repo.insert!()

          {:ok, game |> Repo.preload(:players)}
        end
    end
  end

  def get_players(game) do
    from(p in Player, where: p.game_id == ^game.id, select: p, order_by: [asc: :inserted_at])
    |> Repo.all()
  end

  def get_active_player(game) do
    from(p in Player, where: p.id == ^game.active_player_id, select: p) |> Repo.one!()
  end

  def get_next_player(game) do
    players = get_players(game)

    active_index =
      players
      |> Enum.find_index(fn player ->
        player.id == game.active_player_id
      end)

    players |> Enum.at(rem(active_index + 1, length(players)))
  end

  def is_own_turn(game, color) do
    active_player = get_active_player(game)
    active_player.color == color
  end

  def maybe_make_move(board, own_color, from_cell, to_cell) do
    with true <- is_own_turn(board, own_color),
         true <- BoardService.is_own_movable_piece(board, own_color, from_cell),
         true <- BoardService.is_neighboring_piece(board, from_cell, to_cell),
         true <- BoardService.is_enemy_or_empty(board, own_color, to_cell) do
      {:ok, make_move!(board, from_cell, to_cell)}
    else
      _ -> {:error}
    end
  end

  def is_stronger_than(attacker, defender) do
    cond do
      defender == nil -> true
      attacker == "S" && defender == "1" -> true
      attacker == "8" && defender == "B" -> true
      defender == "F" -> true
      defender == "S" -> true
      true -> String.to_integer(attacker) > String.to_integer(defender)
    end
  end

  def is_equal_rank(attacker, defender) do
    attacker == defender
  end

  defp make_move!(board, {x, y} = from_cell, {a, b} = to_cell) do
    attacker = BoardService.get_piece(board, {x, y})
    defender = BoardService.get_piece(board, {a, b})

    cond do
      is_equal_rank(attacker, defender) -> BoardService.draw_attack(board, from_cell, to_cell)
      is_stronger_than(attacker, defender) -> BoardService.win_attack(board, from_cell, to_cell)
      true -> BoardService.lose_attack(board, from_cell, to_cell)
    end
  end

  def end_turn(game, board) do
    next_player = get_next_player(game)

    Game.changeset(game, %{"active_player_id" => next_player.id, "board" => board})
    |> Repo.update!()
  end
end
