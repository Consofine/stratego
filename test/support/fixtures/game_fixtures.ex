defmodule Stratego.GameFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stratego.Game` context.
  """

  @doc """
  Generate a game_config.
  """
  def game_config_fixture(attrs \\ %{}) do
    {:ok, game_config} =
      attrs
      |> Enum.into(%{
        attackAndMove: true,
        attackerAdvantage: true,
        defenderReveal: true,
        moveToDefeated: true
      })
      |> Stratego.Game.create_game_config()

    game_config
  end

  @doc """
  Generate a board.
  """
  def board_fixture(attrs \\ %{}) do
    {:ok, board} =
      attrs
      |> Enum.into(%{
        board: %{},
        eliminated_players: [],
        game_code: "some game_code",
        graveyard: [],
        number_players: 42,
        turn: 42,
        winner: 42
      })
      |> Stratego.Game.create_board()

    board
  end

  @doc """
  Generate a player.
  """
  def player_fixture(attrs \\ %{}) do
    {:ok, player} =
      attrs
      |> Enum.into(%{
        board: %{},
        color: :blue,
        player_number: 42,
        player_secret: "some player_secret"
      })
      |> Stratego.Game.create_player()

    player
  end
end
