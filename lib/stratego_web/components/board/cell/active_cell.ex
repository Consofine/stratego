defmodule StrategoWeb.Components.Cell.ActiveCell do
  use Phoenix.LiveComponent

  attr(:value, :string, required: true)
  attr(:x, :integer, required: false)
  attr(:y, :integer, required: false)
  attr(:selected, :any, required: false)

  @classMap %{
    "r" => "filter-red",
    "b" => "filter-blue",
    "g" => "filter-green",
    "w" => "filter-white"
  }

  def render(%{value: <<value::binary-size(1)>>} = assigns) when value === "X" do
    # Obstacle
    ~H"""
    <div class="bg-blue-500 h-full w-full" />
    """
  end

  def render(%{value: <<value::binary-size(1)>>} = assigns) when value === "x" do
    # Out of bounds
    ~H"""
    <div class="bg-black h-full w-full" />
    """
  end

  def render(%{value: <<value::binary-size(1), "-", _color::binary>>} = assigns)
      when value == "B" or value == "F" do
    ~H"""
    <button type="button" phx-click="select-piece-active" phx-value-coords={"#{@x},#{@y}"}>
      <div class={"bg-green-500 h-full w-full p-[0.75rem] #{if {@x,@y} == @selected, do: "brightness-75", else: ""}"}>
        <div class="bg-green-500">
          <p class="absolute top-0 left-0 p-1 text-lg font-bold">
            <%= @value |> String.split("-") |> hd() %>
          </p>
          <img
            src={"/images/#{@value |> String.split("-") |> hd()}.svg"}
            class={"filter-#{@value |> String.split("-") |> tl()} p-1"}
          />
        </div>
      </div>
    </button>
    """
  end

  def render(%{value: <<value::binary-size(1), "-", _color::binary>>} = assigns)
      when value == "U" do
    ~H"""
    <button
      type="button"
      class="bg-green-500 h-full w-full p-[0.75rem]"
      phx-click="select-piece-active"
      phx-value-coords={"#{@x},#{@y}"}
    >
      <div class="bg-green-500">
        <img
          src={"/images/#{@value |> String.split("-") |> hd()}.svg"}
          class={"filter-#{@value |> String.split("-") |> tl()} p-1"}
        />
      </div>
    </button>
    """
  end

  def render(%{value: value} = assigns) when value == nil do
    ~H"""
    <button
      type="button"
      class="w-full h-full hover:brightness-90"
      phx-click="select-piece-active"
      phx-value-coords={"#{@x},#{@y}"}
    >
      <div class="bg-green-500 h-full w-full p-2">
        <div class="bg-green-500" />
      </div>
    </button>
    """
  end

  def render(assigns) do
    ~H"""
    <button type="button" phx-click="select-piece-active" phx-value-coords={"#{@x},#{@y}"}>
      <div class={"bg-green-500 h-full w-full p-2 #{if {@x,@y} == @selected, do: "brightness-75", else: ""}"}>
        <div class="bg-green-500">
          <p class="absolute top-0 left-0 p-1 text-lg font-bold">
            <%= @value |> String.split("-") |> hd() %>
          </p>
          <img
            src={"/images/#{@value |> String.split("-") |> hd()}.svg"}
            class={"filter-#{@value |> String.split("-") |> tl()} p-1"}
          />
        </div>
      </div>
    </button>
    """
  end
end
