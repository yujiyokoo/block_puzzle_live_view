defmodule BlockPuzzleLiveView.GameState do
  defstruct board_state: nil,
            block_state: nil,
            frame: 0,
            current_state: :stopped,
            current_state_remaining: -1
end
