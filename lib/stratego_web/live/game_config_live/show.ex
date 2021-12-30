defmodule StrategoWeb.GameConfigLive.Show do
  use StrategoWeb, :live_view

  alias Stratego.Game

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:game_config, Game.get_game_config!(id))}
  end

  defp page_title(:show), do: "Show Game config"
  defp page_title(:edit), do: "Edit Game config"
end
