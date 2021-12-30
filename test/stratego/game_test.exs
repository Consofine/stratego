defmodule Stratego.GameTest do
  use Stratego.DataCase

  alias Stratego.Game

  describe "game_configs" do
    alias Stratego.Game.GameConfig

    import Stratego.GameFixtures

    @invalid_attrs %{attackAndMove: nil, attackerAdvantage: nil, defenderReveal: nil, moveToDefeated: nil}

    test "list_game_configs/0 returns all game_configs" do
      game_config = game_config_fixture()
      assert Game.list_game_configs() == [game_config]
    end

    test "get_game_config!/1 returns the game_config with given id" do
      game_config = game_config_fixture()
      assert Game.get_game_config!(game_config.id) == game_config
    end

    test "create_game_config/1 with valid data creates a game_config" do
      valid_attrs = %{attackAndMove: true, attackerAdvantage: true, defenderReveal: true, moveToDefeated: true}

      assert {:ok, %GameConfig{} = game_config} = Game.create_game_config(valid_attrs)
      assert game_config.attackAndMove == true
      assert game_config.attackerAdvantage == true
      assert game_config.defenderReveal == true
      assert game_config.moveToDefeated == true
    end

    test "create_game_config/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_game_config(@invalid_attrs)
    end

    test "update_game_config/2 with valid data updates the game_config" do
      game_config = game_config_fixture()
      update_attrs = %{attackAndMove: false, attackerAdvantage: false, defenderReveal: false, moveToDefeated: false}

      assert {:ok, %GameConfig{} = game_config} = Game.update_game_config(game_config, update_attrs)
      assert game_config.attackAndMove == false
      assert game_config.attackerAdvantage == false
      assert game_config.defenderReveal == false
      assert game_config.moveToDefeated == false
    end

    test "update_game_config/2 with invalid data returns error changeset" do
      game_config = game_config_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_game_config(game_config, @invalid_attrs)
      assert game_config == Game.get_game_config!(game_config.id)
    end

    test "delete_game_config/1 deletes the game_config" do
      game_config = game_config_fixture()
      assert {:ok, %GameConfig{}} = Game.delete_game_config(game_config)
      assert_raise Ecto.NoResultsError, fn -> Game.get_game_config!(game_config.id) end
    end

    test "change_game_config/1 returns a game_config changeset" do
      game_config = game_config_fixture()
      assert %Ecto.Changeset{} = Game.change_game_config(game_config)
    end
  end

  describe "boards" do
    alias Stratego.Game.Board

    import Stratego.GameFixtures

    @invalid_attrs %{board: nil, eliminated_players: nil, game_code: nil, graveyard: nil, number_players: nil, turn: nil, winner: nil}

    test "list_boards/0 returns all boards" do
      board = board_fixture()
      assert Game.list_boards() == [board]
    end

    test "get_board!/1 returns the board with given id" do
      board = board_fixture()
      assert Game.get_board!(board.id) == board
    end

    test "create_board/1 with valid data creates a board" do
      valid_attrs = %{board: %{}, eliminated_players: [], game_code: "some game_code", graveyard: [], number_players: 42, turn: 42, winner: 42}

      assert {:ok, %Board{} = board} = Game.create_board(valid_attrs)
      assert board.board == %{}
      assert board.eliminated_players == []
      assert board.game_code == "some game_code"
      assert board.graveyard == []
      assert board.number_players == 42
      assert board.turn == 42
      assert board.winner == 42
    end

    test "create_board/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_board(@invalid_attrs)
    end

    test "update_board/2 with valid data updates the board" do
      board = board_fixture()
      update_attrs = %{board: %{}, eliminated_players: [], game_code: "some updated game_code", graveyard: [], number_players: 43, turn: 43, winner: 43}

      assert {:ok, %Board{} = board} = Game.update_board(board, update_attrs)
      assert board.board == %{}
      assert board.eliminated_players == []
      assert board.game_code == "some updated game_code"
      assert board.graveyard == []
      assert board.number_players == 43
      assert board.turn == 43
      assert board.winner == 43
    end

    test "update_board/2 with invalid data returns error changeset" do
      board = board_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_board(board, @invalid_attrs)
      assert board == Game.get_board!(board.id)
    end

    test "delete_board/1 deletes the board" do
      board = board_fixture()
      assert {:ok, %Board{}} = Game.delete_board(board)
      assert_raise Ecto.NoResultsError, fn -> Game.get_board!(board.id) end
    end

    test "change_board/1 returns a board changeset" do
      board = board_fixture()
      assert %Ecto.Changeset{} = Game.change_board(board)
    end
  end

  describe "players" do
    alias Stratego.Game.Player

    import Stratego.GameFixtures

    @invalid_attrs %{board: nil, color: nil, player_number: nil, player_secret: nil}

    test "list_players/0 returns all players" do
      player = player_fixture()
      assert Game.list_players() == [player]
    end

    test "get_player!/1 returns the player with given id" do
      player = player_fixture()
      assert Game.get_player!(player.id) == player
    end

    test "create_player/1 with valid data creates a player" do
      valid_attrs = %{board: %{}, color: :blue, player_number: 42, player_secret: "some player_secret"}

      assert {:ok, %Player{} = player} = Game.create_player(valid_attrs)
      assert player.board == %{}
      assert player.color == :blue
      assert player.player_number == 42
      assert player.player_secret == "some player_secret"
    end

    test "create_player/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_player(@invalid_attrs)
    end

    test "update_player/2 with valid data updates the player" do
      player = player_fixture()
      update_attrs = %{board: %{}, color: :red, player_number: 43, player_secret: "some updated player_secret"}

      assert {:ok, %Player{} = player} = Game.update_player(player, update_attrs)
      assert player.board == %{}
      assert player.color == :red
      assert player.player_number == 43
      assert player.player_secret == "some updated player_secret"
    end

    test "update_player/2 with invalid data returns error changeset" do
      player = player_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_player(player, @invalid_attrs)
      assert player == Game.get_player!(player.id)
    end

    test "delete_player/1 deletes the player" do
      player = player_fixture()
      assert {:ok, %Player{}} = Game.delete_player(player)
      assert_raise Ecto.NoResultsError, fn -> Game.get_player!(player.id) end
    end

    test "change_player/1 returns a player changeset" do
      player = player_fixture()
      assert %Ecto.Changeset{} = Game.change_player(player)
    end
  end
end
