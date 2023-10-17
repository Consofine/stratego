defmodule StrategoWeb.Components.DualBoard do
  use Phoenix.Component

  alias StrategoWeb.Components.Cell.{LobbyCell, ActiveCell}

  # attr :value, :string, required: true
  attr :board, :map, required: false
  attr :self, :map, required: true
  attr :selected, :any, required: true
  attr :status, :string, required: true

  @doc """
  Dual board - in lobby
  """
  def dual_board(%{status: status} = assigns) when status == :in_lobby do
    ~H"""
    <div>
      <div style={"transform: rotate(#{180 + (@self.index * 180)}deg)"}>
        <%= for {row, y} <- Enum.with_index(@board) do %>
          <div class="flex flex-row max-w-full">
            <%= for {cell, x} <- Enum.with_index(row) do %>
              <div
                style={"transform: rotate(-#{180 + (@self.index * 180)}deg)"}
                class="w-16 h-16 flex-0 justify-center items-center relative border border-gray-500 z-10 hover:brightness-90"
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

  @doc """
  Dual board - active game
  """
  def dual_board(%{status: status} = assigns) when status == :active do
    ~H"""
    <p>NOT IN LOBBY</p>
    <div style={"transform: rotate(#{180 + (@self.index * 180)}deg)"}>
      <%= for {row, y} <- Enum.with_index(@board) do %>
        <div class="flex flex-row max-w-full">
          <%= for {cell, x} <- Enum.with_index(row) do %>
            <div
              style={"transform: rotate(-#{180 + (@self.index * 180)}deg)"}
              class="w-16 h-16 flex-0 justify-center items-center relative border border-gray-500 z-10 hover:brightness-90"
            >
              <ActiveCell.active_cell value={cell} x={x} y={y} selected={@selected} />
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
