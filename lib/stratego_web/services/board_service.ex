defmodule StrategoWeb.Services.BoardService do
  alias StrategoWeb.Services.UtilsService
  alias Stratego.Constants
  alias UtilsService

  @pieces_list_duel Constants.pieces_list_duel()
  @pieces_list_quad Constants.pieces_list_quad()
  @obstacles [{2, 4}, {3, 4}, {2, 5}, {3, 5}, {6, 4}, {6, 5}, {7, 4}, {7, 5}]
  @obstacles_four_players [
    {4, 6},
    {4, 7},
    {4, 8},
    {6, 4},
    {7, 4},
    {8, 4},
    {10, 6},
    {10, 7},
    {10, 8},
    {6, 10},
    {7, 10},
    {8, 10}
  ]
  @colors Constants.colors()

  def set_up() do
    board = create_board()
    {:ok, add_starting_pieces(board, 0)}
  end

  def create_board() do
    for y <- 0..9 do
      for x <- 0..9 do
        cond do
          Enum.member?(@obstacles, {x, y}) -> "X"
          true -> nil
        end
      end
    end
  end

  def string_to_atom_color(color) do
    case color do
      "r" -> {:ok, :red}
      "b" -> {:ok, :blue}
      "g" -> {:ok, :green}
      "w" -> {:ok, :white}
      _ -> {:error}
    end
  end

  def atom_to_string_color(color) do
    case color do
      :red -> {:ok, "r"}
      :blue -> {:ok, "b"}
      :green -> {:ok, "g"}
      :white -> {:ok, "w"}
      _ -> {:error}
    end
  end

  def atom_to_string_color!(color) do
    case color do
      :red -> "r"
      :blue -> "b"
      :green -> "g"
      :white -> "w"
    end
  end

  def get_color_from_piece(piece, _format \\ :atom)

  def get_color_from_piece(nil, _format) do
    {:error}
  end

  def get_color_from_piece(piece, :atom) do
    if String.contains?(piece, "-") do
      color = piece |> String.split("-") |> List.last()
      string_to_atom_color(color)
    else
      {:error}
    end
  end

  def get_color_from_piece(piece, :string) do
    if String.contains?(piece, "-") do
      {:ok, piece |> String.split("-") |> List.last()}
    else
      {:error}
    end
  end

  def get_color_from_piece!(piece, :string) do
    piece |> String.split("-") |> List.last()
  end

  def get_color_from_cell(board, x, y) do
    board
    |> Enum.at(y)
    |> Enum.at(x)
    |> get_color_from_piece()
  end

  def is_own_piece(board, player_color, {x, y} = _cell) do
    case get_color_from_cell(board, x, y) do
      {:ok, color} -> color == player_color
      {:error} -> false
    end
  end

  def is_own_piece(piece, player_color) do
    case get_color_from_piece(piece) do
      {:ok, color} -> color == player_color
      {:error} -> false
    end
  end

  def is_own_specific_piece(piece, player_color, rank) do
    is_own_piece(piece, player_color) && get_rank_from_piece(piece) == rank
  end

  def is_two_player_board(board) do
    length(board) == 10
  end

  def is_within_board(board, x, y) do
    x >= 0 && x < length(board) && y >= 0 && y < length(board)
  end

  def is_in_bounds(board, x, y) do
    if is_two_player_board(board) do
      is_within_board(board, x, y) && !is_obstacle_two_player(x, y)
    else
      is_within_board(board, x, y) && !is_out_of_bounds_four_player(x, y) &&
        !is_obstacle_four_player(x, y)
    end
  end

  def index_board(board) do
    board
    |> Enum.with_index(fn row, y ->
      {Enum.with_index(row), y}
    end)
  end

  def get_losers_visible_pieces(board, losers) do
    colors = losers |> Enum.map(fn player -> player.color end)

    index_board(board)
    |> Enum.reduce([], fn {row, y}, acc ->
      acc ++
        Enum.reduce(row, [], fn {piece, x}, row_acc ->
          with {:ok, color} <- get_color_from_piece(piece),
               true <- color in colors do
            row_acc ++ [[UtilsService.coords_to_string({x, y}), piece]]
          else
            _ -> row_acc
          end
        end)
    end)
  end

  @spec is_neighboring_piece(list, {integer, integer}, {integer, integer}) :: boolean
  def is_neighboring_piece(board, {x, y} = _from_cell, {a, b} = _to_cell) do
    is_in_bounds(board, a, b) &&
      Enum.member?([{0, 1}, {0, -1}, {1, 0}, {-1, 0}], {a - x, b - y})
  end

  defp is_valid_row_jump(board, {x, y} = _from_cell, {a, b} = to_cell) do
    cond do
      y != b ->
        false

      max(x, a) - min(x, a) == 1 ->
        is_enemy_or_empty(board, get_color_from_cell(board, x, y), to_cell)

      true ->
        # Don't include start cell, so add 1 from leftmost cell
        {row_start, row_end} = if x < a, do: {x + 1, a}, else: {a + 1, x}

        is_row_clear =
          board
          |> Enum.at(y)
          |> Enum.slice(row_start, row_end)
          |> Enum.filter(fn piece -> piece != nil end)
          |> length() == 0

        is_row_clear && is_enemy_or_empty(board, get_color_from_cell(board, x, y), to_cell)
    end
  end

  defp is_valid_col_jump(board, {x, y} = _from_cell, {a, b} = to_cell) do
    cond do
      x != a ->
        false

      max(y, b) - min(y, b) == 1 ->
        is_enemy_or_empty(board, get_color_from_cell(board, x, y), to_cell)

      true ->
        # Don't include start cell, so add 1 from bottom cell
        {col_start, col_end} = if y < b, do: {y + 1, b}, else: {b + 1, y}

        is_col_clear =
          board
          |> Enum.slice(col_start, col_end - col_start)
          |> Enum.filter(fn row ->
            Enum.at(row, x) != nil
          end)
          |> length() == 0

        is_col_clear && is_enemy_or_empty(board, get_color_from_cell(board, x, y), to_cell)
    end
  end

  @doc """
  Checks if this move is valid for a 9. Checks if the piece is a nine, and verifies
  the destination is in the same column or row with nothing in between it and
  the start square and the end square. Also verifies that the end square is an empty cell or an enemy.
  """
  def is_valid_jump(board, {x, y} = from_cell, {a, b} = to_cell) do
    with "9" <- get_piece_rank(board, from_cell),
         # probs unnecessary but doesn't hurt
         true <- from_cell != to_cell,
         true <- x == a || y == b do
      is_valid_col_jump(board, from_cell, to_cell) || is_valid_row_jump(board, from_cell, to_cell)
    else
      _ -> false
    end
  end

  def is_valid_square(board, from_cell, to_cell) do
    is_neighboring_piece(board, from_cell, to_cell) || is_valid_jump(board, from_cell, to_cell)
  end

  def is_enemy_or_empty(board, team_color, {x, y}) do
    if get_piece(board, {x, y}) == nil do
      true
    else
      case get_color_from_cell(board, x, y) do
        {:ok, color} ->
          color != team_color

        {:error} ->
          false
      end
    end
  end

  defp is_movable(piece_rank) do
    ["S", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    |> Enum.member?(piece_rank)
  end

  @spec is_movable_piece(any(), {integer(), integer()}) :: boolean()
  def is_movable_piece(board, {x, y}) do
    # can't be bomb or flag
    get_piece_rank(board, {x, y}) |> is_movable()
  end

  def is_movable_piece(piece) do
    get_rank_from_piece(piece) |> is_movable()
  end

  def is_own_movable_piece(board, player_color, {x, y}) do
    is_own_piece(board, player_color, {x, y}) && is_movable_piece(board, {x, y})
  end

  def is_own_movable_piece(piece, player_color) do
    is_movable_piece(piece) && is_own_piece(piece, player_color)
  end

  def has_movable_piece(board, player_color) do
    Enum.reduce(board, false, fn row, acc ->
      acc ||
        Enum.reduce(row, false, fn piece, row_acc ->
          row_acc || is_own_movable_piece(piece, player_color)
        end)
    end)
  end

  def has_flag(board, player_color) do
    Enum.reduce(board, false, fn row, acc ->
      acc ||
        Enum.reduce(row, false, fn piece, row_acc ->
          row_acc || is_own_specific_piece(piece, player_color, "F")
        end)
    end)
  end

  def draw_attack(board, from_cell, to_cell) do
    set_piece(board, from_cell, nil) |> set_piece(to_cell, nil)
  end

  def win_attack(board, from_cell, to_cell) do
    attacker = get_piece(board, from_cell)
    set_piece(board, from_cell, nil) |> set_piece(to_cell, attacker)
  end

  def lose_attack(board, from_cell, _to_cell) do
    set_piece(board, from_cell, nil)
  end

  def set_piece(board, {x, y}, piece) do
    row = Enum.at(board, y)
    board |> List.replace_at(y, List.replace_at(row, x, piece))
  end

  def get_rank_from_piece(piece) do
    cond do
      piece == nil -> nil
      String.contains?(piece, "-") -> String.split(piece, "-") |> hd()
      true -> nil
    end
  end

  def get_piece(board, {x, y}) do
    board |> Enum.at(y) |> Enum.at(x)
  end

  def get_piece_rank(board, {x, y}) do
    get_piece(board, {x, y}) |> get_rank_from_piece()
  end

  def get_piece_and_rank(board, cell) do
    piece = get_piece(board, cell)
    {piece, get_rank_from_piece(piece)}
  end

  def swap!(board, {x, y}, {a, b}) do
    first_piece = get_piece(board, {x, y})
    second_piece = get_piece(board, {a, b})
    board = set_piece(board, {x, y}, second_piece)
    set_piece(board, {a, b}, first_piece)
  end

  def is_p1_starting_square_four_player(x, y) do
    x >= 4 && x <= 10 && y <= 2
  end

  def is_p1_starting_square_two_player(_x, y) do
    y < 4
  end

  def get_p1_piece(x, y) do
    piece = Enum.at(@pieces_list_quad, y) |> Enum.at(x - 4)
    color = Enum.at(@colors, 0)
    "#{piece}-#{color}"
  end

  def is_p2_starting_square_four_player(x, y) do
    x >= 12 && y >= 4 && y <= 10
  end

  def is_p2_starting_square_two_player(_x, y) do
    y >= 6
  end

  def get_p2_piece(x, y) do
    piece = Enum.at(@pieces_list_quad, x - 12) |> Enum.at(y - 4)
    color = Enum.at(@colors, 1)
    "#{piece}-#{color}"
  end

  def is_p3_starting_square_four_player(x, y) do
    x >= 4 && x <= 10 && y >= 12
  end

  def get_p3_piece(x, y) do
    piece = Enum.at(@pieces_list_quad, y - 12) |> Enum.at(x - 4)
    color = Enum.at(@colors, 2)
    "#{piece}-#{color}"
  end

  def is_p4_starting_square_four_player(x, y) do
    x <= 2 && y >= 4 && y <= 10
  end

  def get_p4_piece(x, y) do
    piece = Enum.at(@pieces_list_quad, x) |> Enum.at(y - 4)
    color = Enum.at(@colors, 3)
    "#{piece}-#{color}"
  end

  def is_obstacle_four_player(x, y) do
    @obstacles_four_players |> Enum.member?({x, y})
  end

  def is_obstacle_two_player(x, y) do
    @obstacles
    |> Enum.member?({x, y})
  end

  def is_out_top_left(x, y) do
    x <= 3 && y <= 3
  end

  def is_out_top_right(x, y) do
    x >= 11 && y <= 3
  end

  def is_out_bottom_left(x, y) do
    x <= 3 && y >= 11
  end

  def is_out_bottom_right(x, y) do
    x >= 11 && y >= 11
  end

  def is_out_of_bounds_four_player(x, y) do
    is_out_top_left(x, y) || is_out_top_right(x, y) || is_out_bottom_left(x, y) ||
      is_out_bottom_right(x, y)
  end

  def get_piece_four_players(x, y) do
    cond do
      is_p1_starting_square_four_player(x, y) -> get_p1_piece(x, y)
      is_p2_starting_square_four_player(x, y) -> get_p2_piece(x, y)
      is_p3_starting_square_four_player(x, y) -> get_p3_piece(x, y)
      is_obstacle_four_player(x, y) -> "X"
      is_out_of_bounds_four_player(x, y) -> "x"
      true -> nil
    end
  end

  def add_starting_pieces(board, player_number) when player_number == 0 or player_number == 1 do
    color = Constants.colors() |> Enum.at(player_number)

    board
    |> Enum.with_index(fn row, index ->
      case player_number do
        0 when index < 4 ->
          Enum.map(Enum.at(@pieces_list_duel, index), fn piece ->
            piece <> "-" <> color
          end)

        1 when index > 5 ->
          formatted_piece =
            Enum.map(Enum.at(@pieces_list_duel, 9 - index), fn piece ->
              piece <> "-" <> color
            end)

          formatted_piece

        _ ->
          row
      end
    end)
  end

  def add_starting_pieces(_board, player_number) when player_number == 2 do
    for y <- 0..14 do
      for x <- 0..14 do
        get_piece_four_players(x, y)
      end
    end
  end

  def add_starting_pieces(board, player_number) when player_number == 3 do
    Enum.with_index(board, fn row, y ->
      Enum.with_index(row, fn cell, x ->
        if is_p4_starting_square_four_player(x, y) do
          get_p4_piece(x, y)
        else
          cell
        end
      end)
    end)
  end

  def clean_board(board, self_color) do
    clean =
      Enum.map(board, fn row ->
        row
        |> Enum.map(fn piece ->
          case get_color_from_piece(piece, :string) do
            {:ok, color} ->
              if color != atom_to_string_color!(self_color), do: "U-#{color}", else: piece

            {:error} ->
              piece
          end
        end)
      end)

    clean
  end
end
