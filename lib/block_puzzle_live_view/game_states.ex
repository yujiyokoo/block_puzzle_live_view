defmodule BlockPuzzleLiveView.GameStates do
  alias BlockPuzzleLiveView.{GameState, BlockStates, BoardState}

  @stages [:moving, :flashing, :deleting]

  def start_game do
    %GameState{
      board_state: BoardState.new_board(),
      block_state: BlockStates.random_block(),
      running: true
    }
  end

  def lock_block(game_state = %GameState{}) do
    new_board_state = BoardState.place_block(game_state.board_state, game_state.block_state)

    Map.put(game_state, :board_state, new_board_state)
  end

  def delete_full_rows(game_state = %GameState{}) do
    without_full =
      Enum.reject(
        game_state.board_state,
        fn row -> Enum.all?(row, fn elem -> !is_nil(elem) end) end
      )

    Map.put(game_state, :board_state, BoardState.refill(without_full))
  end

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

  def check_game_over(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 0})

    game_over = collide?(block_4x4(game_state.block_state), board_4x4)

    if game_over do
      Map.put(game_state, :running, false)
    else
      game_state
    end
  end

  def can_rotate_counterclockwise?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 0})

    block_4x4 = BlockStates.as_4x4(BlockStates.counterclockwise_next(game_state.block_state))

    !collide?(block_4x4, board_4x4)
  end

  def can_rotate_clockwise?(game_state = %GameState{}) do
    board_4x4 = get_4x4_board(game_state, %{x: 0, y: 0})

    block_4x4 = BlockStates.as_4x4(BlockStates.clockwise_next(game_state.block_state))

    !collide?(block_4x4, board_4x4)
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
