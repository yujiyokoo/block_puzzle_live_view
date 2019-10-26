defmodule BlockPuzzleLiveViewWeb.GameLive do
  use Phoenix.LiveView
  require Phoenix.View

  def render(assigns) do
    Phoenix.View.render(BlockPuzzleLiveViewWeb.PageView, "game.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    if connected?(socket), do: :timer.send_interval(16, self(), :update)
    {:ok, assign(socket, left: false, right: false)}
  end

  def handle_info(:update, socket) do
    {:noreply, assign(socket, left: socket.assigns.left, right: socket.assigns.right)}
  end

  def handle_event("key_down", keys, socket) do
    right =
      if keys["key"] == "ArrowRight" do
        true
      else
        socket.assigns.right
      end

    left =
      if keys["key"] == "ArrowLeft" do
        true
      else
        socket.assigns.left
      end

    {:noreply, assign(socket, left: left, right: right)}
  end

  def handle_event("key_up", keys, socket) do
    right =
      if keys["key"] == "ArrowRight" do
        false
      else
        socket.assigns.right
      end

    left =
      if keys["key"] == "ArrowLeft" do
        false
      else
        socket.assigns.left
      end

    {:noreply, assign(socket, left: left, right: right)}
  end
end
