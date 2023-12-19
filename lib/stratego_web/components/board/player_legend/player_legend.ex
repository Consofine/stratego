defmodule StrategoWeb.Components.PlayerLegend do
  use Phoenix.Component

  require Logger

  attr(:players, :list, required: true)
  attr(:status, :atom, required: true)
  attr(:active_player_id, :integer, required: true)

  def legend(assigns) do
    ~H"""
    <div class="bg-white shadow-md rounded-md border border-gray-300 w-fit max-w-xs p-4">
      <h3 class="text-xl font-medium font-serif text-center mb-2">Players</h3>
      <div :for={player <- @players} class="py-1">
        <StrategoWeb.Components.PlayerLegend.player_legend_item
          status={@status}
          player={player}
          active_player_id={@active_player_id}
        />
      </div>
    </div>
    """
  end

  attr(:player, :any, required: true)
  attr(:status, :atom, required: true)
  attr(:active_player_id, :integer, required: true)

  def player_legend_item(%{status: status} = assigns) when status == :in_lobby do
    ~H"""
    <div class={[
      "p-1 border-l-8 pl-4 w-32 flex flex-row items-center justify-between",
      "border-#{get_color(@player.color)}"
    ]}>
      <div>
        <p class="font-medium"><%= @player.username %></p>
      </div>
      <div>
        <%= if @player.status == :not_ready do %>
          <Heroicons.LiveView.icon name="minus" type="outline" class="h-4 w-4" />
        <% else %>
          <Heroicons.LiveView.icon name="check" type="outline" class="h-4 w-4" />
        <% end %>
      </div>
    </div>
    """
  end

  def player_legend_item(%{status: status, player: player} = assigns)
      when status == :active or status == :completed do
    color = get_color(player.color)
    assigns = assign(assigns, %{color: color})

    ~H"""
    <div class={[
      "p-1 pl-4 w-32",
      if(@active_player_id == @player.id,
        do: "bg-#{color} text-white",
        else: "border-l-8 border-#{color}"
      )
    ]}>
      <p class={["font-medium", if(@player.status == :defeated, do: "line-through", else: "")]}>
        <%= @player.username %>
      </p>
    </div>
    """
  end

  def get_color(color) do
    colors = [
      blue: "blue-500",
      green: "black",
      red: "red-500",
      white: "gray-100"
    ]

    colors[color]
  end
end
