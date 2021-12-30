defmodule StrategoWeb.GameConfigLive.Index do
  use StrategoWeb, :live_view

  alias Stratego.Game
  alias Stratego.Game.GameConfig

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :game_configs, list_game_configs())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Game config")
    |> assign(:game_config, Game.get_game_config!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Game config")
    |> assign(:game_config, %GameConfig{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Game configs")
    |> assign(:game_config, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    game_config = Game.get_game_config!(id)
    {:ok, _} = Game.delete_game_config(game_config)

    {:noreply, assign(socket, :game_configs, list_game_configs())}
  end

  defp list_game_configs do
    Game.list_game_configs()
  end
end
