defmodule StrategoWeb.PlayerLiveTest do
  use StrategoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Stratego.GameFixtures

  @create_attrs %{board: %{}, color: :blue, player_number: 42, player_secret: "some player_secret"}
  @update_attrs %{board: %{}, color: :red, player_number: 43, player_secret: "some updated player_secret"}
  @invalid_attrs %{board: nil, color: nil, player_number: nil, player_secret: nil}

  defp create_player(_) do
    player = player_fixture()
    %{player: player}
  end

  describe "Index" do
    setup [:create_player]

    test "lists all players", %{conn: conn, player: player} do
      {:ok, _index_live, html} = live(conn, Routes.player_index_path(conn, :index))

      assert html =~ "Listing Players"
      assert html =~ player.player_secret
    end

    test "saves new player", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.player_index_path(conn, :index))

      assert index_live |> element("a", "New Player") |> render_click() =~
               "New Player"

      assert_patch(index_live, Routes.player_index_path(conn, :new))

      assert index_live
             |> form("#player-form", player: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#player-form", player: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.player_index_path(conn, :index))

      assert html =~ "Player created successfully"
      assert html =~ "some player_secret"
    end

    test "updates player in listing", %{conn: conn, player: player} do
      {:ok, index_live, _html} = live(conn, Routes.player_index_path(conn, :index))

      assert index_live |> element("#player-#{player.id} a", "Edit") |> render_click() =~
               "Edit Player"

      assert_patch(index_live, Routes.player_index_path(conn, :edit, player))

      assert index_live
             |> form("#player-form", player: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#player-form", player: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.player_index_path(conn, :index))

      assert html =~ "Player updated successfully"
      assert html =~ "some updated player_secret"
    end

    test "deletes player in listing", %{conn: conn, player: player} do
      {:ok, index_live, _html} = live(conn, Routes.player_index_path(conn, :index))

      assert index_live |> element("#player-#{player.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#player-#{player.id}")
    end
  end

  describe "Show" do
    setup [:create_player]

    test "displays player", %{conn: conn, player: player} do
      {:ok, _show_live, html} = live(conn, Routes.player_show_path(conn, :show, player))

      assert html =~ "Show Player"
      assert html =~ player.player_secret
    end

    test "updates player within modal", %{conn: conn, player: player} do
      {:ok, show_live, _html} = live(conn, Routes.player_show_path(conn, :show, player))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Player"

      assert_patch(show_live, Routes.player_show_path(conn, :edit, player))

      assert show_live
             |> form("#player-form", player: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#player-form", player: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.player_show_path(conn, :show, player))

      assert html =~ "Player updated successfully"
      assert html =~ "some updated player_secret"
    end
  end
end
