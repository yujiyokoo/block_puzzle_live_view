defmodule BlockPuzzleLiveView.GameStatesTest do
  use BlockPuzzleLiveViewWeb.ConnCase
  alias BlockPuzzleLiveView.GameStates

  test "start_game gives new empty board" do
    assert GameStates.start_game().board_state == [
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil],
             [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
           ]
  end
end
