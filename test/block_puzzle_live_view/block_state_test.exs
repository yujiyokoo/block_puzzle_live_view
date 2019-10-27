defmodule BlockPuzzleLiveView.BlockStateTest do
  use BlockPuzzleLiveViewWeb.ConnCase

  alias BlockPuzzleLiveView.BlockStates

  test "random gives some block with default orientation" do
    random = BlockStates.random_block()

    assert Enum.member?([:I, :T, :O, :J, :L, :S, :Z], random.shape)
    assert random.orientation == 0
  end
end
