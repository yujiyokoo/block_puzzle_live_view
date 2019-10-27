defmodule BlockPuzzleLiveView.GameStates do
  alias BlockPuzzleLiveView.{GameState, BlockStates, BoardState}

  def start_game do
    %GameState{board_state: BoardState.new_board(), block_state: BlockStates.random_block()}
  end

  def can_drop?(game_state = %GameState{}) do
    # TODO: decide whether to use nil or zero...
    board_state_with_floor =
      (game_state.board_state ++ [BoardState.solid_floor(), BoardState.solid_floor()])
      |> Enum.map(fn row -> Enum.map(row, fn e -> if is_nil(e), do: 0, else: 1 end) end)

    rows =
      Enum.slice(
        board_state_with_floor,
        (game_state.block_state.y + 1)..(game_state.block_state.y + 3 + 1)
      )

    # + 1 above as this is collision check for moving down

    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, game_state.block_state.x..(game_state.block_state.x + 3))
      end)

    block_4x4 =
      BlockStates.as_4x4(game_state.block_state.shape, game_state.block_state.orientation)

    Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
    |> Enum.all?(fn {l, r} -> l == 0 || r == 0 end)

    # get next positions
    # cut out 4x4
    # if collision, false, else true
  end
end
