defmodule StrategoWeb.Components.LobbyStatus do
  use Phoenix.Component
  alias Phoenix.LiveView.JS
  require Logger

  attr(:self_status, :atom, required: true)
  attr(:game_id, :string, required: true)

  def lobby_status(assigns) do
    ~H"""
    <div class="mt-4 p-4 flex flex-col items-center">
      <%= if @self_status == :not_ready do %>
        <h3 class="text-center text-xl font-serif text-white">Not ready</h3>
        <button
          type="button"
          phx-click="ready-up"
          class="rounded-md px-3 py-2 text-white font-bold bg-green-500 hover:bg-green-700 mt-3"
        >
          Ready up
        </button>
      <% else %>
        <h3 class="text-center text-xl font-serif text-white">Ready</h3>
        <div class="mx-auto p-2 max-w-xs bg-teal-500 text-center rounded-md m-2">
          <p class="text-white">Waiting for others</p>
        </div>
      <% end %>
    </div>
    <div class="mt-4 p-4 flex flex-col items-center">
      <h3 class="text-center text-xl font-serif text-white">Invite friends</h3>
      <p class="text-center text-gray-100 text-sm">Code: <%= @game_id %></p>
      <button
        type="button"
        phx-click={JS.dispatch("phx:copy", to: "#game-link")}
        class="rounded-md px-3 py-2 text-white font-bold bg-teal-500 hover:bg-teal-700 mt-3 flex flex-row items-center gap-x-2"
      >
        Copy link <Heroicons.LiveView.icon name="clipboard" type="outline" class="h-4 w-4" />
      </button>
      <input type="hidden" id="game-link" value={"https://militaire.fly.dev/join/#{@game_id}"} />
    </div>
    """
  end
end
