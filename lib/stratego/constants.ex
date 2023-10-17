defmodule Stratego.Constants do
  def max_players() do
    4
  end

  def colors() do
    ["b", "r", "g", "w"]
  end

  def db_colors() do
    [:blue, :red, :green, :white]
  end

  def pieces_list_duel() do
    [
      [
        "9",
        "9",
        "S",
        "B",
        "B",
        "B",
        "B",
        "B",
        "B",
        "F"
      ],
      [
        "8",
        "8",
        "8",
        "8",
        "9",
        "9",
        "9",
        "9",
        "9",
        "9"
      ],
      [
        "5",
        "6",
        "6",
        "6",
        "6",
        "7",
        "7",
        "7",
        "7",
        "8"
      ],
      [
        "1",
        "2",
        "3",
        "3",
        "4",
        "4",
        "4",
        "5",
        "5",
        "5"
      ]
    ]
  end

  def pieces_list_quad() do
    [
      [
        "1",
        "2",
        "3",
        "4",
        "4",
        "5",
        "5"
      ],
      [
        "6",
        "6",
        "8",
        "8",
        "8",
        "8",
        "9"
      ],
      [
        "9",
        "9",
        "S",
        "B",
        "B",
        "B",
        "F"
      ]
    ]
  end
end
