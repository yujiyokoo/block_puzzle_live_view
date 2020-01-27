defmodule BlockPuzzleLiveViewWeb.PageController do
  use BlockPuzzleLiveViewWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: "/game")
  end
end
