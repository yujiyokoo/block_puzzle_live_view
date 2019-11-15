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

    game_state = %GameState{
      board_state: BoardState.new_board(),
      block_state: BlockStates.null_block(),
      current_state: :stopped
    }

    {:ok,
     assign(socket,
       input_state: input_state,
       game_state: game_state,
       cell_colours: cell_colours(game_state)
     )}
  end

  defp cell_colours(game_state = %GameState{current_state: :flashing}) do
    with_block = BoardState.whiten_block(game_state.board_state, game_state.block_state)

    BoardState.cell_colours(with_block)
  end

  defp cell_colours(game_state = %GameState{}) do
    with_block = BoardState.place_block(game_state.board_state, game_state.block_state)

    BoardState.cell_colours(with_block)
  end

  defp get_input(socket) do
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

    down =
      if socket.assigns.input_state.down.pressed do
        socket.assigns.input_state.down |> increase_count
      else
        socket.assigns.input_state.down
      end

    up =
      if socket.assigns.input_state.up.pressed do
        socket.assigns.input_state.up |> increase_count
      else
        socket.assigns.input_state.up
      end

    x =
      if socket.assigns.input_state.x.pressed do
        socket.assigns.input_state.x |> increase_count
      else
        socket.assigns.input_state.x
      end

    z =
      if socket.assigns.input_state.z.pressed do
        socket.assigns.input_state.z |> increase_count
      else
        socket.assigns.input_state.z
      end

    {right, left, down, up, z, x}
  end

  def handle_info(:update, socket) do
    if socket.assigns.game_state.current_state != :stopped do
      do_update(socket)
    else
      {:noreply, socket}
    end
  end

  def do_update(socket) do
    {right, left, down, up, z, x} = get_input(socket)

    input_state =
      Map.merge(socket.assigns.input_state, %{
        left: left,
        right: right,
        up: up,
        down: down,
        z: z,
        x: x
      })

    updated_game_state =
      socket.assigns.game_state
      |> move_left(left)
      |> move_right(right)
      |> rotate_clockwise(z)
      |> rotate_counterclockwise(x)
      |> move_down()
      |> GameStates.flash_block()
      |> GameStates.set_darkening_state()
      |> GameStates.delete_full_rows()
      |> GameStates.get_new_block()
      |> GameStates.check_game_over()
      |> advance_frame()

    {:noreply,
     assign(socket,
       input_state: input_state,
       game_state: updated_game_state,
       cell_colours:
         cell_colours(updated_game_state)
         |> BoardState.darken_full_rows(updated_game_state.current_state)
     )}
  end

  defp advance_frame(game_state = %GameState{}) do
    %{game_state | frame: rem(game_state.frame + 1, 60)}
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

  defp move_down(game_state = %GameState{current_state: :moving}) do
    if GameStates.can_drop?(game_state) do
      if rem(game_state.frame, 10) == 0 do
        %{
          game_state
          | block_state: %{game_state.block_state | y: game_state.block_state.y + 1},
            current_state_remaining: -1
        }
      else
        game_state
      end
    else
      case game_state.current_state_remaining do
        -1 -> %{game_state | current_state_remaining: 60}
        0 -> %{game_state | current_state: :flashing, current_state_remaining: 30}
        _ -> %{game_state | current_state_remaining: game_state.current_state_remaining - 1}
      end
    end
  end

  defp move_down(game_state = %GameState{}), do: game_state

  defp rotate_clockwise(game_state, z) do
    input = z.count == 1

    if input && GameStates.can_rotate_clockwise?(game_state) do
      %{
        game_state
        | block_state: %{
            game_state.block_state
            | orientation: rem(game_state.block_state.orientation + 1, 4)
          }
      }
    else
      game_state
    end
  end

  defp rotate_counterclockwise(game_state, x) do
    input = x.count == 1

    if input && GameStates.can_rotate_counterclockwise?(game_state) do
      %{
        game_state
        | block_state: %{
            game_state.block_state
            | orientation: rem(game_state.block_state.orientation + 3, 4)
          }
      }
    else
      game_state
    end
  end

  defp move_right(game_state, right) do
    right_input = right.count == 1 || (right.count >= 15 && rem(right.count, 6) == 0)

    if right_input && GameStates.can_move_right?(game_state) do
      %{game_state | block_state: %{game_state.block_state | x: game_state.block_state.x + 1}}
    else
      game_state
    end
  end

  defp move_left(game_state = %GameState{current_state: :moving}, left) do
    left_input = left.count == 1 || (left.count >= 15 && rem(left.count, 6) == 0)

    if left_input && GameStates.can_move_left?(game_state) do
      %{game_state | block_state: %{game_state.block_state | x: game_state.block_state.x - 1}}
    else
      game_state
    end
  end

  defp move_left(game_state, _) do
    game_state
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

    up =
      if keys["key"] == "ArrowUp" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.up |> set_pressed)
      else
        socket.assigns.input_state.up
      end

    down =
      if keys["key"] == "ArrowDown" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.down |> set_pressed)
      else
        socket.assigns.input_state.down
      end

    z =
      if keys["key"] == "z" || keys["key"] == "Z" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.z |> set_pressed)
      else
        socket.assigns.input_state.z
      end

    x =
      if keys["key"] == "x" || keys["key"] == "X" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.x |> set_pressed)
      else
        socket.assigns.input_state.x
      end

    input_state =
      Map.merge(socket.assigns.input_state, %{
        left: left,
        right: right,
        up: up,
        down: down,
        x: x,
        z: z
      })

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

    up =
      if keys["key"] == "ArrowUp" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.up |> set_released)
      else
        socket.assigns.input_state.up
      end

    down =
      if keys["key"] == "ArrowDown" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.down |> set_released)
      else
        socket.assigns.input_state.down
      end

    z =
      if keys["key"] == "z" || keys["key"] == "Z" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.z |> set_released)
      else
        socket.assigns.input_state.z
      end

    x =
      if keys["key"] == "x" || keys["key"] == "X" do
        Map.merge(socket.assigns.input_state, socket.assigns.input_state.x |> set_released)
      else
        socket.assigns.input_state.x
      end

    input_state =
      Map.merge(socket.assigns.input_state, %{
        left: left,
        right: right,
        up: up,
        down: down,
        z: z,
        x: x
      })

    game_state =
      if keys["key"] == " " && socket.assigns.game_state.current_state == :stopped do
        GameStates.start_game()
      else
        socket.assigns.game_state
      end

    {:noreply, assign(socket, input_state: input_state, game_state: game_state)}
  end

  defp set_pressed(%{count: count}), do: %{pressed: true, count: count}
  defp set_released(%{}), do: %{pressed: false, count: 0}

  defp increase_count(%{pressed: pressed, count: count}),
    do: %{pressed: pressed, count: count + 1}
end
