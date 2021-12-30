defmodule Stratego.Game do
  @moduledoc """
  The Game context.
  """

  import Ecto.Query, warn: false
  alias Stratego.Repo

  alias Stratego.Game.GameConfig

  @doc """
  Returns the list of game_configs.

  ## Examples

      iex> list_game_configs()
      [%GameConfig{}, ...]

  """
  def list_game_configs do
    Repo.all(GameConfig)
  end

  @doc """
  Gets a single game_config.

  Raises `Ecto.NoResultsError` if the Game config does not exist.

  ## Examples

      iex> get_game_config!(123)
      %GameConfig{}

      iex> get_game_config!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game_config!(id), do: Repo.get!(GameConfig, id)

  @doc """
  Creates a game_config.

  ## Examples

      iex> create_game_config(%{field: value})
      {:ok, %GameConfig{}}

      iex> create_game_config(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game_config(attrs \\ %{}) do
    %GameConfig{}
    |> GameConfig.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game_config.

  ## Examples

      iex> update_game_config(game_config, %{field: new_value})
      {:ok, %GameConfig{}}

      iex> update_game_config(game_config, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game_config(%GameConfig{} = game_config, attrs) do
    game_config
    |> GameConfig.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game_config.

  ## Examples

      iex> delete_game_config(game_config)
      {:ok, %GameConfig{}}

      iex> delete_game_config(game_config)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game_config(%GameConfig{} = game_config) do
    Repo.delete(game_config)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game_config changes.

  ## Examples

      iex> change_game_config(game_config)
      %Ecto.Changeset{data: %GameConfig{}}

  """
  def change_game_config(%GameConfig{} = game_config, attrs \\ %{}) do
    GameConfig.changeset(game_config, attrs)
  end

  alias Stratego.Game.Board

  @doc """
  Returns the list of boards.

  ## Examples

      iex> list_boards()
      [%Board{}, ...]

  """
  def list_boards do
    Repo.all(Board)
  end

  @doc """
  Gets a single board.

  Raises `Ecto.NoResultsError` if the Board does not exist.

  ## Examples

      iex> get_board!(123)
      %Board{}

      iex> get_board!(456)
      ** (Ecto.NoResultsError)

  """
  def get_board!(id), do: Repo.get!(Board, id)

  @doc """
  Creates a board.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Board{}}

      iex> create_board(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a board.

  ## Examples

      iex> update_board(board, %{field: new_value})
      {:ok, %Board{}}

      iex> update_board(board, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a board.

  ## Examples

      iex> delete_board(board)
      {:ok, %Board{}}

      iex> delete_board(board)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking board changes.

  ## Examples

      iex> change_board(board)
      %Ecto.Changeset{data: %Board{}}

  """
  def change_board(%Board{} = board, attrs \\ %{}) do
    Board.changeset(board, attrs)
  end

  alias Stratego.Game.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end
end
