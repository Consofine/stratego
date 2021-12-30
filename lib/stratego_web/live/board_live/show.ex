defmodule StrategoWeb.BoardLive.Show do
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
     |> assign(:board, Game.get_board!(id))}
  end

  defp page_title(:show), do: "Show Board"
  defp page_title(:edit), do: "Edit Board"
end
