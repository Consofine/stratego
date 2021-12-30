defmodule StrategoWeb.BoardLive.FormComponent do
  use StrategoWeb, :live_component

  alias Stratego.Game

  @impl true
  def update(%{board: board} = assigns, socket) do
    changeset = Game.change_board(board)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"board" => board_params}, socket) do
    changeset =
      socket.assigns.board
      |> Game.change_board(board_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"board" => board_params}, socket) do
    save_board(socket, socket.assigns.action, board_params)
  end

  defp save_board(socket, :edit, board_params) do
    case Game.update_board(socket.assigns.board, board_params) do
      {:ok, _board} ->
        {:noreply,
         socket
         |> put_flash(:info, "Board updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_board(socket, :new, board_params) do
    case Game.create_board(board_params) do
      {:ok, _board} ->
        {:noreply,
         socket
         |> put_flash(:info, "Board created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
