defmodule Stratego.Game.GameConfig do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_configs" do
    field :attack_and_move, :boolean, default: false
    field :attacker_advantage, :boolean, default: false
    field :defender_reveal, :boolean, default: false
    field :move_to_defeated, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(game_config, attrs) do
    game_config
    |> cast(attrs, [:attack_and_move, :move_to_defeated, :attacker_advantage, :defender_reveal])
    |> validate_required([
      :attack_and_move,
      :move_to_defeated,
      :attacker_advantage,
      :defender_reveal
    ])
  end
end
