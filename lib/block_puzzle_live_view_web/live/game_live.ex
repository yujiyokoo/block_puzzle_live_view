defmodule BlockPuzzleLiveViewWeb.Live.GameLive do
  use Phoenix.LiveView
  require Phoenix.View
  alias BlockPuzzleLiveView.{BoardState, GameStates, GameState}

  def render(assigns) do
    Phoenix.View.render(BlockPuzzleLiveViewWeb.PageView, "game.html", assigns)
  end

  def mount(%{user_id: user_id}, socket) do
    if connected?(socket), do: :timer.send_interval(16, self(), :update)

    input_state = %InputState{}
    game_state = GameStates.start_game()

    {:ok,
     assign(socket,
       input_state: input_state,
       game_state: game_state,
       cell_colours: cell_colours(game_state)
     )}
  end

  defp cell_colours(game_state = %GameState{}) do
    with_block = BoardState.place_block(game_state.board_state, game_state.block_state)

    BoardState.cell_colours(with_block)
  end

  def handle_info(:update, socket) do
    right =
      if socket.assigns.input_state.right.pressed do
        socket.assigns.input_state.right |> increase_count
      else
        socket.assigns.input_state.right
      end

    left =
      if socket.assigns.input_state.left.pressed do
        socket.assigns.input_state.left |> increase_count
      else
        socket.assigns.input_state.left
      end

    input_state = Map.merge(socket.assigns.input_state, %{left: left, right: right})

    new_block_state =
      socket.assigns.game_state.block_state
      |> move_left(left)
      |> move_right(right)

    dropped_block_state =
      new_block_state
      |> move_down(socket.assigns.game_state)

    updated_game_state =
      socket.assigns.game_state
      |> Map.put(:block_state, dropped_block_state)
      |> Map.put(:frame, rem(socket.assigns.game_state.frame + 1, 60))

    {:noreply,
     assign(socket,
       input_state: input_state,
       game_state: updated_game_state,
       cell_colours: cell_colours(updated_game_state)
     )}
  end

  defp move_down(blk_st = %{}, game_state) do
    if rem(game_state.frame, 3) == 0 && GameStates.can_drop?(game_state) do
      Map.put(blk_st, :y, blk_st.y + 1)
    else
      blk_st
    end
  end

  defp move_right(blk_st = %{}, right) do
    if right.count == 1 || (right.count >= 5 && rem(right.count, 6) == 0) do
      Map.put(blk_st, :x, blk_st.x + 1)
    else
      blk_st
    end
  end

  defp move_left(blk_st = %{}, left) do
    if left.count == 1 || (left.count >= 5 && rem(left.count, 6) == 0) do
      Map.put(blk_st, :x, blk_st.x - 1)
    else
      blk_st
    end
  end

  def handle_event("key_down", keys, socket) do
    right =
      if keys["key"] == "ArrowRight" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.right |> set_pressed)
      else
        socket.assigns.input_state.right
      end

    left =
      if keys["key"] == "ArrowLeft" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.left |> set_pressed)
      else
        socket.assigns.input_state.left
      end

    input_state = Map.merge(socket.assigns.input_state, %{left: left, right: right})

    {:noreply, assign(socket, input_state: input_state)}
  end

  def handle_event("key_up", keys, socket) do
    right =
      if keys["key"] == "ArrowRight" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.right |> set_released)
      else
        socket.assigns.input_state.right
      end

    left =
      if keys["key"] == "ArrowLeft" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.left |> set_released)
      else
        socket.assigns.input_state.left
      end

    input_state = Map.merge(socket.assigns.input_state, %{left: left, right: right})

    {:noreply, assign(socket, input_state: input_state)}
  end

  defp set_pressed(%{count: count}), do: %{pressed: true, count: count}
  defp set_released(%{}), do: %{pressed: false, count: 0}

  defp increase_count(%{pressed: pressed, count: count}),
    do: %{pressed: pressed, count: count + 1}
end