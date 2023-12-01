defmodule StrategoWeb.Components.Cell.ActiveCell do
  alias StrategoWeb.Services.BoardService

  use Phoenix.LiveComponent

  attr(:value, :string, required: true)
  attr(:x, :integer, required: false)
  attr(:y, :integer, required: false)
  attr(:selected, :any, required: false)
  attr(:vp_list, :list, required: true)

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

  def render(%{value: <<value::binary-size(1), "-", color::binary>>, vp_list: vp_list} = assigns)
      when value == "U" and length(vp_list) === 2 do
    winner =
      vp_list
      |> Enum.find(fn piece ->
        BoardService.get_color_from_piece!(piece, :string) == color
      end)

    loser =
      vp_list
      |> Enum.find(fn piece ->
        BoardService.get_color_from_piece!(piece, :string) != color
      end)

    assigns = assign(assigns, :loser, loser) |> assign(:winner, winner)

    ~H"""
    <button
      type="button"
      class="bg-green-500 h-full w-full p-[0.75rem]"
      phx-click="select-piece-active"
      phx-value-coords={"#{@x},#{@y}"}
    >
      <div class="bg-green-500">
        <%!-- Winner --%>
        <p class="absolute top-0 left-0 p-1 text-lg font-bold">
          <%= @winner |> String.split("-") |> hd() %>
        </p>
        <img
          src={"/images/#{@winner |> String.split("-") |> hd()}.svg"}
          class={"filter-#{@winner |> String.split("-") |> tl()} p-1"}
        />
        <%!-- Loser --%>
        <p class={[
          "font-bold px-1 absolute top-0 right-0 rounded-lg",
          "filter-#{@loser |> String.split("-") |> tl()}"
        ]}>
          <%= @loser |> String.split("-") |> hd() %>
        </p>
      </div>
    </button>
    """
  end

  def render(%{value: <<value::binary-size(1), "-", _color::binary>>, vp_list: vp_list} = assigns)
      when value == "U" do
    assigns =
      if length(vp_list) > 0 do
        assign(assigns, :vp, List.first(vp_list))
      else
        assign(assigns, :vp, nil)
      end

    ~H"""
    <button
      type="button"
      class="bg-green-500 h-full w-full p-[0.75rem]"
      phx-click="select-piece-active"
      phx-value-coords={"#{@x},#{@y}"}
    >
      <div class={["bg-green-500", if(@vp, do: "opacity-75", else: "")]}>
        <%= if @vp do %>
          <p class="absolute top-0 left-0 p-1 text-lg font-bold">
            <%= @vp |> String.split("-") |> hd() %>
          </p>
          <img
            src={"/images/#{@vp |> String.split("-") |> hd()}.svg"}
            class={"filter-#{@vp |> String.split("-") |> tl()} p-1"}
          />
        <% else %>
          <img
            src={"/images/#{@value |> String.split("-") |> hd()}.svg"}
            class={"filter-#{@value |> String.split("-") |> tl()} p-1"}
          />
        <% end %>
      </div>
    </button>
    """
  end

  def render(%{value: value, vp_list: vp_list} = assigns) when value == nil do
    assigns =
      if length(vp_list) > 0 do
        assign(assigns, :vp, List.first(vp_list))
      else
        assign(assigns, :vp, nil)
      end

    ~H"""
    <button
      type="button"
      class="w-full h-full hover:brightness-90"
      phx-click="select-piece-active"
      phx-value-coords={"#{@x},#{@y}"}
    >
      <div class="bg-green-500 h-full w-full p-2">
        <div class={["bg-green-500", if(@vp, do: "opacity-50", else: "")]}>
          <%= if @vp do %>
            <p class="absolute top-0 left-0 p-1 text-lg font-bold opacity-50">
              <%= @vp |> String.split("-") |> hd() %>
            </p>
            <img
              src={"/images/#{@vp |> String.split("-") |> hd()}.svg"}
              class={"filter-#{@vp |> String.split("-") |> tl()} p-1 opacity-75"}
            />
          <% end %>
        </div>
      </div>
    </button>
    """
  end

  def render(%{vp_list: vp_list} = assigns) do
    assigns =
      if length(vp_list) > 0 do
        assign(assigns, :vp, List.first(vp_list))
      else
        assign(assigns, :vp, nil)
      end

    ~H"""
    <button type="button" phx-click="select-piece-active" phx-value-coords={"#{@x},#{@y}"}>
      <div class={"bg-green-500 h-full w-full p-2 #{if {@x,@y} == @selected, do: "brightness-75", else: ""}"}>
        <div class="bg-green-500">
          <p class="absolute top-0 left-0 p-1 text-lg font-bold">
            <%= @value |> String.split("-") |> hd() %>
          </p>
          <%= if @vp && @vp != @value do %>
            <p class={[
              "font-bold px-1 absolute top-0 right-0 rounded-lg",
              "filter-#{@vp |> String.split("-") |> tl()}"
            ]}>
              <%= @vp |> String.split("-") |> hd() %>
            </p>
          <% end %>
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
