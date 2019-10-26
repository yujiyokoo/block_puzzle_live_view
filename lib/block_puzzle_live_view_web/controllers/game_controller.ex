defmodule BlockPuzzleLiveView.GameController do
  import Phoenix.LiveView.Controller
  alias Plug.Conn

  def show(conn, %{"id" => id}) do
    live_render(conn, BlockPuzzleLiveView.PageView,
      session: %{
        id: id,
        current_user_id: Conn.get_session(conn, :user_id)
      }
    )
  end
end
