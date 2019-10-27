defmodule BlockPuzzleLiveView.GameStateTest do
  use BlockPuzzleLiveViewWeb.ConnCase
  alias BlockPuzzleLiveView.GameState

  test "default state has no board" do
    state = %GameState{}

    assert is_nil(state.board_state)
  end

  test "default state has no block" do
    state = %GameState{}

    assert is_nil(state.block_state)
  end
end
