defmodule BlockPuzzleLiveView.GameStates do
  alias BlockPuzzleLiveView.{GameState, BlockStates, BoardState}

  @stages [:stopped, :moving, :flashing, :row_darkening, :row_deleting, :landed]

  def start_game do
    %GameState{
      board_state: BoardState.new_board(),
      block_state: BlockStates.next_block(),
      current_state: :moving
    }
  end

  def flash_block(game_state = %GameState{current_state: :flashing}) do
    if game_state.current_state_remaining >= 0 do
      new_board_state = BoardState.place_block(game_state.board_state, game_state.block_state)

      %{
        game_state
        | board_state: new_board_state,
          current_state_remaining: game_state.current_state_remaining - 1
      }
    else
      %{game_state | current_state: :row_darkening, current_state_remaining: 30}
    end
  end

  def flash_block(game_state = %GameState{}), do: game_state

  def set_darkening_state(
        game_state = %GameState{current_state: :row_darkening, current_state_remaining: 0}
      ) do
    %{game_state | current_state: :row_deleting}
  end

  def set_darkening_state(game_state = %GameState{current_state: :row_darkening}) do
    remaining = game_state.current_state_remaining - 1

    %{game_state | current_state_remaining: remaining}
  end

  def set_darkening_state(game_state = %GameState{}), do: game_state

  def delete_full_rows(game_state = %GameState{current_state: :row_deleting}) do
    without_full =
      Enum.reject(
        game_state.board_state,
        fn row -> Enum.all?(row, fn elem -> !is_nil(elem) end) end
      )

    %{
      game_state
      | board_state: BoardState.refill(without_full),
        current_state: :getting_new_block
    }
  end

  def delete_full_rows(game_state = %GameState{}), do: game_state

  def get_new_block(game_state = %GameState{current_state: :getting_new_block}) do
    %{
      game_state
      | block_state: BlockStates.next_block(),
        current_state: :moving,
        current_state_remaining: -1
    }
  end

  def get_new_block(game_state = %GameState{}), do: game_state

  defp collide?(block, board) do
    Enum.zip(List.flatten(block), List.flatten(board))
    |> Enum.any?(fn {l, r} -> !is_nil(l) && !is_nil(r) end)
  end

  defp board_4x4(board, block_state, adjustments, movements = %{}) do
    adjusted_x = block_state.x + adjustments.x + movements.x
    adjusted_y = block_state.y + adjustments.y + movements.y

    rows = Enum.slice(board, adjusted_y..(adjusted_y + 3))

    board_4x4 = Enum.map(rows, fn row -> Enum.slice(row, adjusted_x..(adjusted_x + 3)) end)
  end

  def check_game_over(game_state = %GameState{current_state: :moving}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 0})

    game_over = collide?(block_4x4(game_state.block_state), board_4x4)

    if game_over do
      Map.put(game_state, :current_state, :stopped)
    else
      game_state
    end
  end

  def check_game_over(game_state = %GameState{}), do: game_state

  def can_rotate_counterclockwise?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 0})

    block_section = BlockStates.as_4x4(BlockStates.counterclockwise_next(game_state.block_state))

    !collide?(block_section, board_4x4)
  end

  def rotate_clockwise_no_move?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 0})

    block_section = BlockStates.as_4x4(BlockStates.clockwise_next(game_state.block_state))

    if !collide?(block_section, board_4x4) do
      %{x: 0, y: 0}
    else
      false
    end
  end

  def rotate_with_kick?(game_state = %GameState{}, shift = %{}) do
    board_4x4 = get_4x4_board(game_state, shift)
    block_section = BlockStates.as_4x4(BlockStates.clockwise_next(game_state.block_state))

    !collide?(block_section, board_4x4)
  end

  def rotate_clockwise_with_left_kick?(game_state = %GameState{}) do
    shift_1_right = %{x: 1, y: 0}
    shift_2_right = %{x: 2, y: 0}

    if rotate_with_kick?(game_state, shift_1_right) do
      shift_1_right
    else
      if game_state.block_state.shape == :I && rotate_with_kick?(game_state, shift_2_right) do
        shift_2_right
      else
        false
      end
    end
  end

  def rotate_clockwise_with_right_kick?(game_state = %GameState{}) do
    shift_1_left = %{x: -1, y: 0}
    shift_2_left = %{x: -2, y: 0}

    if rotate_with_kick?(game_state, shift_1_left) do
      shift_1_left
    else
      if game_state.block_state.shape == :I && rotate_with_kick?(game_state, shift_2_left) do
        shift_2_left
      else
        false
      end
    end
  end

  def rotate_clockwise_with_floor_kick?(game_state = %GameState{}) do
    shift_1_up = %{x: 0, y: -1}
    shift_2_up = %{x: 0, y: -1}

    if rotate_with_kick?(game_state, shift_1_up) do
      shift_1_up
    else
      if game_state.block_state.shape == :I && rotate_with_kick?(game_state, shift_2_up) do
        shift_2_up
      else
        false
      end
    end
  end

  def can_move_left?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: -1, y: 0})

    !collide?(block_4x4(game_state.block_state), board_4x4)
  end

  def can_move_right?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 1, y: 0})

    !collide?(block_4x4(game_state.block_state), board_4x4)
  end

  def can_drop?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 1})

    !collide?(block_4x4(game_state.block_state), board_4x4)
  end

  defp get_4x4_board(game_state = %GameState{}, movement) do
    {extended_board, adjustments} = BoardState.extend_board(game_state.board_state)
    board_4x4(extended_board, game_state.block_state, adjustments, movement)
  end

  defp block_4x4(block_state) do
    BlockStates.as_4x4(block_state)
    |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)
  end
end
