defmodule StrategoWeb.HomeLive do
  use StrategoWeb, :live_view
  use Ecto.Schema
  require Logger
  import Ecto.Changeset, only: [change: 2]
  alias Stratego.Game.{Player, Board, GameConfig}
  alias StrategoWeb.{JoinChangeset, CustomErrors}
  alias Stratego.Repo

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_join_changeset() |> assign_create_changeset()}
  end

  defp generate_game_code(depth \\ 0) do
    if depth >= 10 do
      raise CustomErrors.NoIDsError
    end

    secret = hd(Ecto.UUID.generate() |> String.split("-"))

    if Repo.get_by(Board, game_code: secret) do
      generate_game_code(depth + 1)
    else
      secret
    end
  end

  defp generate_player_secret(depth \\ 0) do
    if depth >= 10 do
      raise CustomErrors.NoIDsError
    end

    secret = hd(Ecto.UUID.generate() |> String.split("-"))

    if Repo.get_by(Player, player_secret: secret) do
      generate_player_secret(depth + 1)
    else
      secret
    end
  end

  defp get_player_changeset(username \\ "") do
    player = %Player{}

    player
    |> Player.changeset(%{
      board: %{},
      color: :blue,
      player_number: 0,
      username: username
    })
  end

  defp get_board_changeset(config_id) do
    code = generate_game_code()

    Ecto.Changeset.cast(
      %Board{},
      %{
        board: %{},
        eliminated_players: [],
        game_code: code,
        graveyard: [],
        number_players: 1,
        turn: 0,
        winner: nil,
        config: config_id
      },
      Board.__schema__(:fields)
    )
  end

  defp get_config_changeset(game_config \\ %{}) do
    GameConfig.changeset(%GameConfig{}, %{})
  end

  defp get_join_changeset(attrs \\ %{}) do
    JoinChangeset.changeset(%JoinChangeset{}, attrs)
  end

  defp assign_join_changeset(socket, changeset \\ nil) do
    case changeset do
      nil -> socket |> assign(join_changeset: get_join_changeset())
      _ -> socket |> assign(join_changeset: changeset)
    end
  end

  defp assign_create_changeset(socket, changeset \\ nil) do
    case changeset do
      nil -> socket |> assign(create_changeset: get_player_changeset())
      _ -> socket |> assign(create_changeset: changeset)
    end
  end

  def handle_event("join_game", %{"join_changeset" => request}, socket) do
    Logger.debug("Joining game")

    join_changeset =
      get_join_changeset(%{username: request["username"], game_code: request["game_code"]})

    player_changeset = get_player_changeset(request["username"])

    if !join_changeset.valid? do
      {:noreply,
       socket
       |> assign_create_changeset()
       |> assign_join_changeset(join_changeset |> Map.put(:action, :validate))}
    else
      try do
        board = Repo.get_by!(Board, game_code: request["game_code"])

        if board.is_game_started do
          raise CustomErrors.GameStartedError
        end

        Ecto.Multi.new()
        |> Ecto.Multi.run(:player_struct, fn repo, %{} ->
          #  insert new player model
          secret = generate_player_secret()
          Logger.debug("Secret is #{secret}")

          repo.insert(
            Ecto.Changeset.cast(player_changeset, %{board_id: board.id, player_secret: secret}, [
              :board_id,
              :player_secret
            ])
          )
        end)
        |> Ecto.Multi.run(:board_struct, fn repo, %{} ->
          # increment number of players in game
          repo.update(change(board, number_players: board.number_players + 1))
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{board_struct: board_struct, player_struct: player_struct}} ->
            # Successful insert/update. Redirect
            {:noreply,
             push_redirect(socket,
               to: "/play/#{board_struct.game_code}/#{player_struct.player_secret}"
             )}

          {:error, _player_cs} ->
            {:noreply,
             put_flash(
               socket
               |> assign_create_changeset()
               |> assign_join_changeset(join_changeset |> Map.put(:action, :validate)),
               :error,
               "Error creating player! Please try again"
             )}
        end
      rescue
        Ecto.NoResultsError ->
          {:noreply,
           put_flash(
             socket
             |> assign_join_changeset(join_changeset |> Map.put(:action, :validate))
             |> assign_create_changeset(),
             :error,
             "No game with this code exists. Did you use the wrong code?"
           )}

        e in CustomErrors.GameStartedError ->
          {:noreply,
           put_flash(
             socket
             |> assign_join_changeset(join_changeset |> Map.put(:action, :validate))
             |> assign_create_changeset(),
             :error,
             e.message
           )}

        e in CustomErrors.NoIDsError ->
          {:noreply,
           put_flash(
             socket
             |> assign_join_changeset(join_changeset |> Map.put(:action, :validate))
             |> assign_create_changeset(),
             :error,
             e.message
           )}
      end
    end
  end

  def handle_event("create_game", %{"player" => player}, socket) do
    Logger.debug("Creating game")
    player_changeset = get_player_changeset(player["username"])

    if player_changeset.valid? do
      try do
        Ecto.Multi.new()
        |> Ecto.Multi.insert(:config, get_config_changeset())
        |> Ecto.Multi.run(:board, fn repo, %{config: config} ->
          repo.insert(get_board_changeset(config.id))
        end)
        |> Ecto.Multi.run(:player, fn repo, %{board: board} ->
          secret = generate_player_secret()
          Logger.debug("Player secret is #{secret}")

          repo.insert(
            Ecto.Changeset.cast(
              player_changeset,
              %{board_id: board.id, player_secret: secret, is_host: true},
              [
                :board_id,
                :player_secret,
                :is_host
              ]
            )
          )
        end)
        |> Repo.transaction()
        |> case do
          {:ok, %{board: board, player: player}} ->
            {:noreply,
             push_redirect(socket, to: "/play/#{board.game_code}/#{player.player_secret}")}

          _ ->
            Logger.error("Something went wrong inserting game!")

            {:noreply,
             socket
             |> assign_create_changeset(player_changeset |> Map.put(:action, :validate))
             |> assign_join_changeset()}
        end
      rescue
        e in CustomErrors.NoIDsError ->
          {:noreply,
           put_flash(
             socket
             |> assign_create_changeset(player_changeset |> Map.put(:action, :validate))
             |> assign_join_changeset(),
             :error,
             e.message
           )}
      end
    else
      {:noreply,
       socket
       |> assign_create_changeset(player_changeset |> Map.put(:action, :validate))
       |> assign_join_changeset()}
    end
  end
end
