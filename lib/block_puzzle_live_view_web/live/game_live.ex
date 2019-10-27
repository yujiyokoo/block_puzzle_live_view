defmodule BlockPuzzleLiveViewWeb.Live.GameLive do
  use Phoenix.LiveView
  require Phoenix.View
  alias BlockPuzzleLiveView.{BlockStates, BoardState, GameStates, GameState}

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
      |> move_left(socket.assigns.game_state, left)
      |> move_right(socket.assigns.game_state, right)

    dropped_block_state =
      new_block_state
      |> move_down(socket.assigns.game_state)

    updated_game_state =
      socket.assigns.game_state
      |> Map.put(:block_state, dropped_block_state)
      |> update_frames_since_landing()
      |> lock_block_after_delay()
      |> Map.put(:frame, rem(socket.assigns.game_state.frame + 1, 60))

    {:noreply,
     assign(socket,
       input_state: input_state,
       game_state: updated_game_state,
       cell_colours: cell_colours(updated_game_state)
     )}
  end

  defp update_frames_since_landing(game_state) do
    frames_since_landing =
      if !GameStates.can_drop?(game_state) do
        game_state.frames_since_landing + 1
      else
        0
      end

    Map.put(game_state, :frames_since_landing, frames_since_landing)
  end

  defp lock_block_after_delay(game_state) do
    if game_state.frames_since_landing > 30 do
      GameStates.lock_block(game_state)
      |> get_new_block()
    else
      game_state
    end
  end

  defp get_new_block(game_state) do
    Map.put(game_state, :block_state, BlockStates.random_block())
  end

  # TODO: blk_st is not necessary?
  defp move_down(blk_st = %{}, game_state) do
    if rem(game_state.frame, 3) == 0 && GameStates.can_drop?(game_state) do
      Map.put(blk_st, :y, blk_st.y + 1)
    else
      blk_st
    end
  end

  defp move_right(blk_st = %{}, game_state, right) do
    right_input = right.count == 1 || (right.count >= 5 && rem(right.count, 6) == 0)

    if right_input && GameStates.can_move_right?(game_state) do
      Map.put(blk_st, :x, blk_st.x + 1)
    else
      blk_st
    end
  end

  defp move_left(blk_st = %{}, game_state, left) do
    left_input = left.count == 1 || (left.count >= 5 && rem(left.count, 6) == 0)

    if left_input && GameStates.can_move_left?(game_state) do
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
