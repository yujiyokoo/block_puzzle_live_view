defmodule BlockPuzzleLiveView.BoardState do
  @empty_row [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil]
  @solid_floor [:block, :block, :block, :block, :block, :block, :block, :block, :block, :block]
  @empty_board List.duplicate(@empty_row, 20)

  alias BlockPuzzleLiveView.{BlockState, BlockStates}

  def new_board do
    @empty_board
  end

  def solid_floor, do: @solid_floor
  def empty_row, do: @empty_row

  def refill(rows) do
    List.duplicate(@empty_row, 20 - Enum.count(rows)) ++ rows
  end

  def extend_board(board_state) do
    extended_board =
      ([empty_row()] ++ board_state ++ [solid_floor(), solid_floor()])
      |> Enum.map(fn row -> [:block, :block, :block] ++ row ++ [:block, :block] end)

    {extended_board, %{x: 3, y: 1}}
  end

  def place_block(board, block_state = %BlockState{}) do
    start_row = if block_state.y < 0, do: 0, else: block_state.y
    block_row_nums = Enum.to_list(start_row..(block_state.y + 3))

    Enum.to_list(0..(length(board) - 1))
    |> Enum.map(fn row_idx ->
      board_row = Enum.at(board, row_idx)

      if Enum.member?(block_row_nums, row_idx) do
        block_row =
          BlockStates.as_4x4(block_state)
          |> Enum.at(row_idx - block_state.y)

        cols_to_update = Enum.to_list(block_state.x..(block_state.x + 3))

        Enum.to_list(0..(length(board_row) - 1))
        |> Enum.map(fn col_idx ->
          if Enum.member?(cols_to_update, col_idx) &&
               Enum.at(block_row, col_idx - block_state.x) == 1 do
            BlockStates.colour(block_state.shape)
          else
            Enum.at(board_row, col_idx)
          end
        end)
      else
        board_row
      end
    end)
  end

  def cell_colours(board) do
    Enum.map(board, fn row -> Enum.map(row, &cell_to_colour/1) end)
  end

  defp cell_to_colour(nil), do: ""
  defp cell_to_colour(colour), do: Atom.to_string(colour)
end
