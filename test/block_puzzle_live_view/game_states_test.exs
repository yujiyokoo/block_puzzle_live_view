defmodule BlockPuzzleLiveView.GameStatesTest do
  use BlockPuzzleLiveViewWeb.ConnCase
  alias BlockPuzzleLiveView.GameStates
  alias BlockPuzzleLiveView.BlockState

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

  test "can_drop? is true if nothing blocking at game start" do
    state = GameStates.start_game()

    assert GameStates.can_drop?(state)
  end

  test "can_drop? is false at the bottom of the screen" do
    state =
      GameStates.start_game()
      |> Map.put(:block_state, %{shape: :O, orientation: 0, x: 3, y: 18})

    refute GameStates.can_drop?(state)
  end

  test "can_move_right? is true if nothing blocking at game start" do
    state = GameStates.start_game()

    assert GameStates.can_move_right?(state)
  end

  test "can_move_right? is false at the edge of the screen" do
    state =
      GameStates.start_game()
      |> Map.put(:block_state, %{shape: :O, orientation: 0, x: 7, y: 0})

    refute GameStates.can_move_right?(state)
  end

  test "can_move_left? is true if nothing blocking at game start" do
    state = GameStates.start_game()

    assert GameStates.can_move_left?(state)
  end

  test "can_move_left? is false at the edge of the screen" do
    state =
      GameStates.start_game()
      |> Map.put(:block_state, %BlockState{shape: :O, orientation: 0, x: -1, y: 0})

    refute GameStates.can_move_left?(state)
  end

  test "lock_block locks the block in its place" do
    state =
      GameStates.start_game()
      |> Map.put(:block_state, %BlockState{shape: :O, orientation: 0, x: 0, y: 18})

    new_state = GameStates.lock_block(state)

    assert Enum.at(new_state.board_state, 18) ==
             [nil, :yellow, :yellow, nil, nil, nil, nil, nil, nil, nil]

    assert Enum.at(new_state.board_state, 19) ==
             [nil, :yellow, :yellow, nil, nil, nil, nil, nil, nil, nil]
  end
end
