defmodule StrategoWeb.ErrorLive do
  use StrategoWeb, :live_view

  def mount(%{"error" => error}, _session, socket) do
    {error_header, error_message} = get_error_info(error)
    {:ok, socket |> assign(:error_header, error_header) |> assign(:error_message, error_message)}
  end

  def mount(_params, _session, socket) do
    {error_header, error_message} = get_error_info(nil)
    {:ok, socket |> assign(:error_header, error_header) |> assign(:error_message, error_message)}
  end

  defp get_error_info("invalid_session") do
    {"Invalid session",
     "You're not supposed to be here. You may have tried to join a game you don't belong in."}
  end

  defp get_error_info("no_session") do
    {"No session",
     "Looks like you either navigated here by mistake, or cleared your browser data since starting the game."}
  end

  defp get_error_info("not_found") do
    {"Game not found",
     "We couldn't find this game. Either it doesn't exist, or it's already been started."}
  end

  defp get_error_info(_undefined_error) do
    {"Something went wrong",
     "Oops, looks like something went wrong here. Head back to the home page to start or join a game."}
  end
end
