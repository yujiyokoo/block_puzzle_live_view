defmodule BlockPuzzleLiveViewWeb.Live.GameLive do
  use Phoenix.LiveView
  require Phoenix.View

  alias BlockPuzzleLiveView.{
    BlockState,
    BlockStates,
    BoardState,
    GameStates,
    GameState,
    InputState
  }

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
       cell_colours: cell_colours(game_state),
       next_block_pane: next_block_pane(game_state.upcoming_block),
       score: game_state.score * 100
     )}
  end

  defp next_block_pane(block) do
    block
    |> BlockStates.as_4x4()
    |> Enum.map(fn row ->
      Enum.map(row, fn cell ->
        if cell == 1, do: BlockStates.colour(block.shape)
      end)
    end)
  end

  defp cell_colours(game_state = %GameState{current_state: :flashing}) do
    with_block_and_landing_position =
      game_state.board_state
      |> BoardState.lighten_block(game_state.landing_position)
      |> BoardState.whiten_block(game_state.block_state)

    BoardState.cell_colours(with_block_and_landing_position)
  end

  defp cell_colours(game_state = %GameState{}) do
    with_block_and_landing_position =
      game_state.board_state
      |> BoardState.lighten_block(game_state.landing_position)
      |> BoardState.place_block(game_state.block_state)

    BoardState.cell_colours(with_block_and_landing_position)
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
      |> hard_drop(up)
      |> move_left(left)
      |> move_right(right)
      |> rotate(:clockwise, z)
      |> rotate(:counter_cw, x)
      |> move_down(down)
      |> set_landing_position()
      |> GameStates.flash_block()
      |> GameStates.set_darkening_state()
      |> GameStates.increment_score()
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
         |> BoardState.darken_full_rows(updated_game_state.current_state),
       next_block_pane: next_block_pane(updated_game_state.upcoming_block),
       score: updated_game_state.score * 100
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

  defp move_down(game_state = %GameState{current_state: :moving}, down) do
    down_input = down.count == 1 || (down.count >= 15 && rem(down.count, 6) == 0)

    if GameStates.can_drop?(game_state) do
      if down_input || rem(game_state.frame, 10) == 0 do
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
        0 -> %{game_state | current_state: :flashing, current_state_remaining: 10}
        _ -> %{game_state | current_state_remaining: game_state.current_state_remaining - 1}
      end
    end
  end

  defp move_down(game_state = %GameState{}, _), do: game_state

  defp rotate(game_state = %GameState{current_state: :moving}, direction, %{count: 1}) do
    cond do
      shift = GameStates.rotate_no_move?(game_state, direction) ->
        %{game_state | block_state: BlockStates.rotate(game_state.block_state, direction, shift)}

      shift = GameStates.rotate_with_floor_kick?(game_state, direction) ->
        %{
          game_state
          | block_state: BlockStates.rotate(game_state.block_state, direction, shift)
        }

      shift = GameStates.rotate_with_left_kick?(game_state, direction) ->
        %{
          game_state
          | block_state: BlockStates.rotate(game_state.block_state, direction, shift)
        }

      shift = GameStates.rotate_with_right_kick?(game_state, direction) ->
        %{
          game_state
          | block_state: BlockStates.rotate(game_state.block_state, direction, shift)
        }

      true ->
        game_state
    end
  end

  defp rotate(game_state, _, _), do: game_state

  defp move_right(game_state = %GameState{current_state: :moving}, right) do
    right_input = right.count == 1 || (right.count >= 15 && rem(right.count, 6) == 0)

    if right_input && GameStates.can_move_right?(game_state) do
      %{game_state | block_state: %{game_state.block_state | x: game_state.block_state.x + 1}}
    else
      game_state
    end
  end

  defp move_right(game_state, _), do: game_state

  defp set_landing_position(game_state = %GameState{current_state: :moving}) do
    %{block_state: landing_position} = hard_drop_position(game_state)
    %{game_state | landing_position: landing_position}
  end

  defp set_landing_position(game_state = %GameState{}), do: game_state

  defp hard_drop(game_state = %GameState{current_state: :moving}, up) do
    up_input = up.count == 1 || (up.count >= 15 && rem(up.count, 6) == 0)

    if up_input do
      %{block_state: block_state} = hard_drop_position(game_state)

      %{
        game_state
        | block_state: %{
            game_state.block_state
            | y: block_state.y
          },
          current_state: :flashing,
          current_state_remaining: 10
      }
    else
      game_state
    end
  end

  defp hard_drop(game_state, _), do: game_state

  defp hard_drop_position(game_state) do
    if GameStates.can_drop?(game_state) do
      hard_drop_position(%{
        game_state
        | block_state: %{game_state.block_state | y: game_state.block_state.y + 1}
      })
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

  defp move_left(game_state, _), do: game_state

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
