defmodule BlockPuzzleLiveView.GameLive do
  use Phoenix.LiveView

  def render(assigns) do
    Phoenix.View.render(BlockPuzzleLiveView.PageView, "game.html", assigns)
  end
end
