defmodule StrategoWeb.HomeController do
  use StrategoWeb, :controller
  alias StrategoWeb.Services.PlayerService
  alias StrategoWeb.Services.{GameService}
  alias Stratego.{Forms.CreateGame, Forms.JoinGame, Constants}
  import Ecto.Changeset
  require Logger
  @db_colors Constants.db_colors()

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    create_cs = CreateGame.changeset(%CreateGame{}, %{})
    join_cs = JoinGame.changeset(%JoinGame{}, %{})

    render(conn |> assign(:create_cs, create_cs) |> assign(:join_cs, join_cs), :home,
      layout: false
    )
  end

  def create(conn, %{"create_game" => create_game_params}) do
    cs = CreateGame.changeset(%CreateGame{}, create_game_params)

    username = get_field(cs, :username)
    secret = Ecto.UUID.generate()

    with true <- cs.valid?,
         {:ok, game} <- GameService.create_game(),
         {:ok, _game} = GameService.join_game(game.uid, %{username: username, secret: secret}) do
      redirect(conn |> put_session(:secret, secret), to: ~p(/play/#{game.uid}))
    else
      _ ->
        Logger.debug("NO GOOD")
        join_cs = JoinGame.changeset(%JoinGame{}, %{})
        render(conn |> assign(:create_cs, cs) |> assign(:join_cs, join_cs), :home, layout: false)
    end
  end

  def join(conn, %{"join_game" => join_game_params}) do
    Logger.critical("PARAMS: #{inspect(join_game_params)}")
    cs = JoinGame.changeset(%JoinGame{}, join_game_params)

    if cs.valid? do
      game_uid = get_field(cs, :game_id) |> String.upcase()
      username = get_field(cs, :username)
      secret = Ecto.UUID.generate()

      with {:ok, _game} <-
             GameService.join_game(game_uid, %{username: username, secret: secret}) do
        redirect(conn |> put_session(:secret, secret), to: ~p(/play/#{game_uid}))
      else
        {:error, error} ->
          Logger.critical("ERROR: #{error}")
          create_cs = CreateGame.changeset(%CreateGame{}, %{})
          render(conn |> assign(:create_cs, create_cs) |> assign(:join_cs, cs), :home)
      end
    else
      create_cs = CreateGame.changeset(%CreateGame{}, %{})
      render(conn |> assign(:create_cs, create_cs) |> assign(:join_cs, cs), :home)
    end
  end
end
