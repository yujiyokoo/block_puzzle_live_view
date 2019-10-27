defmodule BlockPuzzleLiveView.GameStates do
  alias BlockPuzzleLiveView.{GameState, BlockStates, BoardState}

  def start_game do
    %GameState{board_state: BoardState.new_board(), block_state: BlockStates.random_block()}
  end
end
