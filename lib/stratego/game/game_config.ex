defmodule Stratego.Game.GameConfig do
  use Ecto.Schema
  import Ecto.Changeset

  schema "game_configs" do
    field :attackAndMove, :boolean, default: false
    field :attackerAdvantage, :boolean, default: false
    field :defenderReveal, :boolean, default: false
    field :moveToDefeated, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(game_config, attrs) do
    game_config
    |> cast(attrs, [:attackAndMove, :moveToDefeated, :attackerAdvantage, :defenderReveal])
    |> validate_required([:attackAndMove, :moveToDefeated, :attackerAdvantage, :defenderReveal])
  end
end
