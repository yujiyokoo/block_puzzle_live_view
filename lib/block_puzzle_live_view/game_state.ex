defmodule BlockPuzzleLiveView.GameState do
  defstruct board_state: nil,
            block_state: nil,
            upcoming_block: nil,
            frame: 0,
            score: 0,
            total_deleted_lines: 0,
            current_state: :stopped,
            current_state_remaining: -1,
            landing_position: nil
end
