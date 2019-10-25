defmodule BlockPuzzleLiveViewWeb.PageController do
  use BlockPuzzleLiveViewWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
