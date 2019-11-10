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

  test "extend_board adds 2 left and 2 right, 1 above and 2 below" do
    {extended_board, _} =
      BoardState.new_board()
      |> BoardState.extend_board()

    # height is 1 top + 20 game space + 2 floor
    assert Enum.count(extended_board) == 23

    # width is 3 wall + 10 game spcae + 2 wall
    assert Enum.count(Enum.at(extended_board, 0)) == 15

    # 2 solid floors
    assert Enum.at(extended_board, 21) == List.duplicate(:block, 15)
    assert Enum.at(extended_board, 22) == List.duplicate(:block, 15)
  end

  test "extend_board returns adjustments for x and y" do
    {_, adjustments} =
      BoardState.new_board()
      |> BoardState.extend_board()

    assert adjustments.x == 3
    assert adjustments.y == 1
  end
end
