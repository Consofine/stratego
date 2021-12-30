defmodule StrategoWeb.GameConfigLiveTest do
  use StrategoWeb.ConnCase

  import Phoenix.LiveViewTest
  import Stratego.GameFixtures

  @create_attrs %{attackAndMove: true, attackerAdvantage: true, defenderReveal: true, moveToDefeated: true}
  @update_attrs %{attackAndMove: false, attackerAdvantage: false, defenderReveal: false, moveToDefeated: false}
  @invalid_attrs %{attackAndMove: false, attackerAdvantage: false, defenderReveal: false, moveToDefeated: false}

  defp create_game_config(_) do
    game_config = game_config_fixture()
    %{game_config: game_config}
  end

  describe "Index" do
    setup [:create_game_config]

    test "lists all game_configs", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.game_config_index_path(conn, :index))

      assert html =~ "Listing Game configs"
    end

    test "saves new game_config", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.game_config_index_path(conn, :index))

      assert index_live |> element("a", "New Game config") |> render_click() =~
               "New Game config"

      assert_patch(index_live, Routes.game_config_index_path(conn, :new))

      assert index_live
             |> form("#game_config-form", game_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#game_config-form", game_config: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.game_config_index_path(conn, :index))

      assert html =~ "Game config created successfully"
    end

    test "updates game_config in listing", %{conn: conn, game_config: game_config} do
      {:ok, index_live, _html} = live(conn, Routes.game_config_index_path(conn, :index))

      assert index_live |> element("#game_config-#{game_config.id} a", "Edit") |> render_click() =~
               "Edit Game config"

      assert_patch(index_live, Routes.game_config_index_path(conn, :edit, game_config))

      assert index_live
             |> form("#game_config-form", game_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#game_config-form", game_config: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.game_config_index_path(conn, :index))

      assert html =~ "Game config updated successfully"
    end

    test "deletes game_config in listing", %{conn: conn, game_config: game_config} do
      {:ok, index_live, _html} = live(conn, Routes.game_config_index_path(conn, :index))

      assert index_live |> element("#game_config-#{game_config.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#game_config-#{game_config.id}")
    end
  end

  describe "Show" do
    setup [:create_game_config]

    test "displays game_config", %{conn: conn, game_config: game_config} do
      {:ok, _show_live, html} = live(conn, Routes.game_config_show_path(conn, :show, game_config))

      assert html =~ "Show Game config"
    end

    test "updates game_config within modal", %{conn: conn, game_config: game_config} do
      {:ok, show_live, _html} = live(conn, Routes.game_config_show_path(conn, :show, game_config))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Game config"

      assert_patch(show_live, Routes.game_config_show_path(conn, :edit, game_config))

      assert show_live
             |> form("#game_config-form", game_config: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#game_config-form", game_config: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.game_config_show_path(conn, :show, game_config))

      assert html =~ "Game config updated successfully"
    end
  end
end
