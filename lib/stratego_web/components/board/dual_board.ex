defmodule StrategoWeb.Components.DualBoard do
  use Phoenix.LiveComponent

  require Logger

  alias StrategoWeb.Components.Cell.CompletedCell
  alias StrategoWeb.Services.{UtilsService, BoardService}
  alias StrategoWeb.Components.Cell.{LobbyCell, ActiveCell}

  def is_starting_square(self, {x, y}) do
    case self.index do
      0 -> BoardService.is_p1_starting_square_two_player(x, y)
      1 -> BoardService.is_p2_starting_square_two_player(x, y)
    end
  end

  def get_vp_list(visible_pieces, cell) do
    visible_pieces
    |> Enum.filter(fn [coords, _piece] ->
      UtilsService.coords_to_string(cell) == coords
    end)
    |> Enum.map(fn [_coords, piece] ->
      piece
    end)
  end

  def render(%{game: game} = assigns) when game.status == :in_lobby do
    ~H"""
    <div>
      <div style={"transform: rotate(#{180 + (@self.index * 180)}deg)"}>
        <%= for {row, y} <- Enum.with_index(@game.board) do %>
          <div class="flex flex-row max-w-full">
            <%= for {cell, x} <- Enum.with_index(row) do %>
              <div
                style={"transform: rotate(-#{180 + (@self.index * 180)}deg)"}
                class={"w-14 h-14 flex-0 justify-center items-center relative border border-gray-500 z-10 #{if is_starting_square(@self, {x,y}), do: "hover:brightness-90", else: ""}"}
              >
                <LobbyCell.lobby_cell value={cell} x={x} y={y} selected={@selected} />
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{game: game} = assigns) when game.status == :active do
    ~H"""
    <div>
      <div style={"transform: rotate(#{180 + (@self.index * 180)}deg)"}>
        <%= for {row, y} <- Enum.with_index(@game.board) do %>
          <div class="flex flex-row max-w-full">
            <%= for {cell, x} <- Enum.with_index(row) do %>
              <div
                style={"transform: rotate(-#{180 + (@self.index * 180)}deg)"}
                class={"w-16 h-16 flex-0 justify-center items-center relative border border-gray-500 z-10 #{if is_starting_square(@self, {x,y}), do: "hover:brightness-90", else: ""}"}
              >
                <.live_component
                  module={ActiveCell}
                  id={"#{x}-#{y}"}
                  value={cell}
                  x={x}
                  y={y}
                  selected={@selected}
                  vp_list={get_vp_list(@game.visible_pieces, {x, y})}
                />
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  def render(%{game: game} = assigns) when game.status == :completed do
    ~H"""
    <div>
      <div style={"transform: rotate(#{180 + (@self.index * 180)}deg)"}>
        <%= for {row, y} <- Enum.with_index(@game.board) do %>
          <div class="flex flex-row max-w-full">
            <%= for {cell, x} <- Enum.with_index(row) do %>
              <div
                style={"transform: rotate(-#{180 + (@self.index * 180)}deg)"}
                class="w-16 h-16 flex-0 justify-center items-center relative border border-gray-500 z-10"
              >
                <.live_component
                  module={CompletedCell}
                  id={"#{x}-#{y}"}
                  value={cell}
                  x={x}
                  y={y}
                  vp_list={get_vp_list(@game.visible_pieces, {x, y})}
                />
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
