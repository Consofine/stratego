defmodule StrategoWeb.GameConfigLive.FormComponent do
  use StrategoWeb, :live_component

  alias Stratego.Game

  @impl true
  def update(%{game_config: game_config} = assigns, socket) do
    changeset = Game.change_game_config(game_config)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"game_config" => game_config_params}, socket) do
    changeset =
      socket.assigns.game_config
      |> Game.change_game_config(game_config_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"game_config" => game_config_params}, socket) do
    save_game_config(socket, socket.assigns.action, game_config_params)
  end

  defp save_game_config(socket, :edit, game_config_params) do
    case Game.update_game_config(socket.assigns.game_config, game_config_params) do
      {:ok, _game_config} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game config updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_game_config(socket, :new, game_config_params) do
    case Game.create_game_config(game_config_params) do
      {:ok, _game_config} ->
        {:noreply,
         socket
         |> put_flash(:info, "Game config created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
