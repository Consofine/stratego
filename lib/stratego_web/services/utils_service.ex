defmodule StrategoWeb.Services.UtilsService do
  @moduledoc """
  Service to help with utilities such as parsing, conversions, etc.
  """

  def parse_coordinates_string(coords) do
    with true <- String.contains?(coords, ","),
         coordinates <- String.split(coords, ","),
         2 <- length(coordinates),
         {x, ""} <- Integer.parse(coordinates |> List.first()),
         {y, ""} <- Integer.parse(coordinates |> List.last()) do
      {:ok, {x, y}}
    else
      _ -> {:error}
    end
  end

  def coords_to_string({x, y}) do
    "#{x},#{y}"
  end

  defp get_string_for_piece(piece) do
    cond do
      piece == nil -> "   "
      String.length(piece) == 1 -> " #{piece} "
      true -> piece
    end
  end

  def stringify_board(board) do
    "\n" <>
      (board
       |> Enum.map(fn row ->
         row |> Enum.map(&get_string_for_piece(&1)) |> Enum.join(" ")
       end)
       |> Enum.join("\n"))
  end
end
