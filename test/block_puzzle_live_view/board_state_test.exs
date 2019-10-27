defmodule BlockPuzzleLiveView.BoardStateTest do
  use BlockPuzzleLiveViewWeb.ConnCase

  alias BlockPuzzleLiveView.{BoardState, BlockState, BlockStates}

  test "place_block adds block to board" do
    board = BoardState.new_board()
    block_state = %BlockState{shape: :O, orientation: 0, x: 3, y: 0}
    with_block = BoardState.place_block(board, block_state)

    assert with_block ==
             List.duplicate([nil, nil, nil, nil, :yellow, :yellow, nil, nil, nil, nil], 2) ++
               List.duplicate([nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], 18)
  end

  test "place_block works fine when placed above 0 line" do
    board = BoardState.new_board()
    block_state = %BlockState{shape: :O, orientation: 0, x: 3, y: -1}
    with_block = BoardState.place_block(board, block_state)

    assert with_block ==
             [[nil, nil, nil, nil, :yellow, :yellow, nil, nil, nil, nil]] ++
               List.duplicate([nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], 19)
  end
end
