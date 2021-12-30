defmodule StrategoWeb.PlayerLive do
  use StrategoWeb, :live_view
  alias Stratego.Game.Player
  require Logger

  def mount(_params, _session, socket) do
    changeset = Player.changeset(%Player{}, %{})
    {:ok, assign(socket, changeset: changeset)}
  end

  def handle_event("add", %{"player" => player}, socket) do
    # Todos.create_todo(todo)
    Logger.debug("Got here!")
    Logger.debug("#{inspect(player)}")
    {:noreply, socket}
  end
end
