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
    place_block_with_colour(board, block_state, BlockStates.colour(block_state.shape))
  end

  def whiten_block(board, block_state = %BlockState{}) do
    place_block_with_colour(board, block_state, :white)
  end

  def lighten_block(board, block_state = %BlockState{}) do
    place_block_with_colour(board, block_state, :lightgrey)
  end

  def lighten_block(board, _), do: board

  defp place_block_with_colour(board, block_state = %BlockState{}, colour) do
    start_row = if block_state.y < 0, do: 0, else: block_state.y
    block_row_nums = Enum.to_list(start_row..(block_state.y + 3))

    indexes_of(board)
    |> Enum.map(fn row_idx ->
      process_row(row_idx, Enum.at(board, row_idx), block_state, block_row_nums, colour)
    end)
  end

  defp indexes_of(board), do: Enum.to_list(0..(length(board) - 1))

  defp process_row(row_idx, board_row, block_state, block_row_nums, colour) do
    if Enum.member?(block_row_nums, row_idx) do
      indexes_of(board_row)
      |> Enum.map(fn col_idx ->
        board_cell_or_block(col_idx, block_state, board_row, row_idx, colour)
      end)
    else
      board_row
    end
  end

  defp board_cell_or_block(col_idx, block_state, board_row, row_idx, colour) do
    col_idxs_to_update = Enum.to_list(block_state.x..(block_state.x + 3))

    block_row =
      BlockStates.as_4x4(block_state)
      |> Enum.at(row_idx - block_state.y)

    if Enum.member?(col_idxs_to_update, col_idx) &&
         !is_nil(Enum.at(block_row, col_idx - block_state.x)) do
      colour
    else
      Enum.at(board_row, col_idx)
    end
  end

  def darken_full_rows(board_state, :row_darkening) do
    Enum.map(
      board_state,
      fn row ->
        if Enum.all?(row, fn elem -> !is_nil(elem) end) do
          Enum.map(row, fn _cell -> :grey end)
        else
          row
        end
      end
    )
  end

  def darken_full_rows(board_state, _), do: board_state

  def cell_colours(board) do
    Enum.map(board, fn row -> Enum.map(row, &cell_to_colour/1) end)
  end

  defp cell_to_colour(nil), do: nil
  defp cell_to_colour(colour), do: Atom.to_string(colour)
end
