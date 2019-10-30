defmodule BlockPuzzleLiveView.GameStates do
  alias BlockPuzzleLiveView.{GameState, BlockStates, BoardState}

  def start_game do
    %GameState{
      board_state: BoardState.new_board(),
      block_state: BlockStates.random_block(),
      running: true
    }
  end

  def lock_block(game_state = %GameState{}) do
    new_board_state = BoardState.place_block(game_state.board_state, game_state.block_state)

    Map.put(game_state, :board_state, new_board_state)
  end

  def delete_full_rows(game_state = %GameState{}) do
    without_full =
      Enum.reject(
        game_state.board_state,
        fn row -> Enum.all?(row, fn elem -> !is_nil(elem) end) end
      )

    Map.put(game_state, :board_state, BoardState.refill(without_full))
  end

  def check_game_over(game_state = %GameState{}) do
    board_state_with_floor_and_walls =
      (game_state.board_state ++ [BoardState.solid_floor()])
      |> Enum.map(fn row -> [:blok] ++ row ++ [:block] end)

    extended_board = [:blok] ++ BoardState.empty_row() ++ [:block]

    rows =
      Enum.slice(
        board_state_with_floor_and_walls,
        (game_state.block_state.y + 1)..(game_state.block_state.y + 1 + 3)
      )

    # + 1 as left wall has been added
    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, (game_state.block_state.x + 1)..(game_state.block_state.x + 3 + 1))
      end)

    # TODO: decide whether to use nil or zero...
    block_4x4 =
      BlockStates.as_4x4(game_state.block_state)
      |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)

    game_over =
      Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
      |> Enum.any?(fn {l, r} -> !is_nil(l) && !is_nil(r) end)

    if game_over do
      Map.put(game_state, :running, false)
    else
      game_state
    end
  end

  def can_rotate_counterclockwise?(game_state = %GameState{}) do
    board_state_with_floor_and_walls =
      (game_state.board_state ++ [BoardState.solid_floor()])
      |> Enum.map(fn row -> [:blok] ++ row ++ [:block] end)

    rows =
      Enum.slice(
        board_state_with_floor_and_walls,
        game_state.block_state.y..(game_state.block_state.y + 3)
      )

    # + 1 as left wall has been added
    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, (game_state.block_state.x + 1)..(game_state.block_state.x + 3 + 1))
      end)

    # TODO: decide whether to use nil or zero...
    block_4x4 =
      BlockStates.as_4x4(BlockStates.counterclockwise_next(game_state.block_state))
      |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)

    Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
    |> Enum.all?(fn {l, r} -> is_nil(l) || is_nil(r) end)
  end

  def can_rotate_clockwise?(game_state = %GameState{}) do
    board_state_with_floor_and_walls =
      (game_state.board_state ++ [BoardState.solid_floor()])
      |> Enum.map(fn row -> [:blok] ++ row ++ [:block] end)

    rows =
      Enum.slice(
        board_state_with_floor_and_walls,
        game_state.block_state.y..(game_state.block_state.y + 3)
      )

    # + 1 as left wall has been added
    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, (game_state.block_state.x + 1)..(game_state.block_state.x + 3 + 1))
      end)

    # TODO: decide whether to use nil or zero...
    block_4x4 =
      BlockStates.as_4x4(BlockStates.clockwise_next(game_state.block_state))
      |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)

    Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
    |> Enum.all?(fn {l, r} -> is_nil(l) || is_nil(r) end)
  end

  def can_move_left?(game_state = %GameState{}) do
    board_state_with_left_wall =
      game_state.board_state
      |> Enum.map(fn row -> [:block, :block] ++ row end)

    rows =
      Enum.slice(
        board_state_with_left_wall,
        game_state.block_state.y..(game_state.block_state.y + 3)
      )

    # board has shifted to right by 2 when adding the left wall.
    # so adding 1 here as this needs to work when x = -1
    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, (game_state.block_state.x + 1)..(game_state.block_state.x + 3 + 1))
      end)

    # TODO: decide whether to use nil or zero...
    block_4x4 =
      BlockStates.as_4x4(game_state.block_state)
      |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)

    Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
    |> Enum.all?(fn {l, r} -> is_nil(l) || is_nil(r) end)
  end

  def can_move_right?(game_state = %GameState{}) do
    board_state_with_right_wall =
      game_state.board_state
      |> Enum.map(fn row -> row ++ [:block, :block] end)

    rows =
      Enum.slice(
        board_state_with_right_wall,
        game_state.block_state.y..(game_state.block_state.y + 3)
      )

    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, (game_state.block_state.x + 1)..(game_state.block_state.x + 3 + 1))
      end)

    # TODO: decide whether to use nil or zero...
    block_4x4 =
      BlockStates.as_4x4(game_state.block_state)
      |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)

    Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
    |> Enum.all?(fn {l, r} -> is_nil(l) || is_nil(r) end)
  end

  def can_drop?(game_state = %GameState{}) do
    board_state_with_floor_and_walls =
      (game_state.board_state ++ [BoardState.solid_floor()])
      |> Enum.map(fn row -> [:block] ++ row ++ [:block, :block] end)

    # + 1 as this is collision check for moving down
    rows =
      Enum.slice(
        board_state_with_floor_and_walls,
        (game_state.block_state.y + 1)..(game_state.block_state.y + 3 + 1)
      )

    # + 1 as left wall has been added
    board_4x4 =
      Enum.map(rows, fn row ->
        Enum.slice(row, (game_state.block_state.x + 1)..(game_state.block_state.x + 3 + 1))
      end)

    # TODO: decide whether to use nil or zero...
    block_4x4 =
      BlockStates.as_4x4(game_state.block_state)
      |> Enum.map(fn row -> Enum.map(row, fn e -> if e == 0, do: nil, else: e end) end)

    Enum.zip(List.flatten(block_4x4), List.flatten(board_4x4))
    |> Enum.all?(fn {l, r} -> is_nil(l) || is_nil(r) end)
  end
end
