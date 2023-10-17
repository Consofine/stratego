defmodule StrategoWeb.Components.QuadBoard do
  use Phoenix.Component

  attr :board, :map, required: true
  attr :selected, :any, required: true
  attr :self, :map, required: true

  def quad_board(assigns) do
    ~H"""
    <div style={"transform: rotate(#{180 - (@self.index  * 90)}deg)"}>
      <%= for {row, y} <- Enum.with_index(@board) do %>
        <div class="flex flex-row max-w-full">
          <%= for {cell, x} <- Enum.with_index(row) do %>
            <div
              style={"transform: rotate(-#{180 - (@self.index * 90)}deg)"}
              class="w-12 h-12 flex-0 justify-center items-center relative border border-gray-500 z-10 hover:brightness-90"
            >
              <StrategoWeb.Components.Cell.cell value={cell} x={x} y={y} selected={@selected} />
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
