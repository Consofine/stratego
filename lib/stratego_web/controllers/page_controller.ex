defmodule StrategoWeb.PageController do
  use StrategoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
