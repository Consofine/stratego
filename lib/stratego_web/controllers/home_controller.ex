defmodule StrategoWeb.HomeController do
  use StrategoWeb, :controller
  alias StrategoWeb.Services.{GameService}
  alias Stratego.{Forms.CreateGame, Forms.JoinGame, Constants}
  import Ecto.Changeset
  @db_colors Constants.db_colors()

  def home(conn, _params) do
    conn |> render(:home)
  end

  def join(conn, params) do
    cs = JoinGame.changeset(%JoinGame{}, params)

    conn
    |> assign_create_cs()
    |> assign_join_cs(cs)
    |> render(:join)
  end

  def create(conn, params) do
    cs = CreateGame.changeset(%CreateGame{}, params)

    conn
    |> assign_create_cs(cs)
    |> assign_join_cs()
    |> render(:create)
  end

  def error(conn, params) do
    conn |> render(:error)
  end

  def create_game(conn, %{"create_game" => create_game_params}) do
    cs = CreateGame.changeset(%CreateGame{}, create_game_params)

    username = get_field(cs, :username)
    secret = Ecto.UUID.generate()

    with true <- cs.valid?,
         {:ok, game} <- GameService.create_game(),
         {:ok, _game} = GameService.join_game(game.uid, %{username: username, secret: secret}) do
      redirect(conn |> put_session(:secret, secret), to: ~p(/play/#{game.uid}))
    else
      _ ->
        conn |> redirect(to: ~p(/create?#{create_game_params}))
    end
  end

  def join_game(conn, %{"join_game" => join_game_params}) do
    cs = JoinGame.changeset(%JoinGame{}, join_game_params)

    game_uid = get_field(cs, :game_id) |> String.upcase()
    username = get_field(cs, :username)
    secret = Ecto.UUID.generate()

    with true <- cs.valid?,
         {:ok, _game} <-
           GameService.join_game(game_uid, %{username: username, secret: secret}) do
      redirect(conn |> put_session(:secret, secret), to: ~p(/play/#{game_uid}))
    else
      _ ->
        cs =
          %{cs | action: :validate}
          |> add_error(
            :game_id,
            "Game ID not found. This game may already have started."
          )

        conn
        |> assign_join_cs(cs)
        |> render(:join)
    end
  end

  defp assign_create_cs(conn, create_cs \\ nil) do
    create_cs = create_cs || CreateGame.changeset(%CreateGame{}, %{})
    conn |> assign(:create_cs, create_cs)
  end

  defp assign_join_cs(conn, join_cs \\ nil) do
    join_cs = join_cs || JoinGame.changeset(%JoinGame{}, %{})
    conn |> assign(:join_cs, join_cs)
  end
end
