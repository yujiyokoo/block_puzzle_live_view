defmodule BlockPuzzleLiveView.BlockStates do
  alias BlockPuzzleLiveView.BlockState

  def as_4x4(block_state) do
    Enum.at(all_4x4s[block_state.shape], block_state.orientation)
  end

  def rotate(block_state = %BlockState{}, direction, shift_param = %{}) do
    shift = Map.merge(%{x: 0, y: 0}, shift_param)

    %{
      block_state
      | orientation: next_orientation(block_state.orientation, direction),
        x: block_state.x + shift.x,
        y: block_state.y + shift.y
    }
  end

  defp next_orientation(orientation, :clockwise), do: rem(orientation + 1, 4)
  defp next_orientation(orientation, :counter_cw), do: rem(orientation + 3, 4)

  def colour(shape) do
    %{I: :cyan, O: :yellow, L: :orange, J: :blue, S: :green, Z: :red, T: :purple, NULL: :none}[
      shape
    ]
  end

  def next_block(blk) do
    %BlockState{
      x: 3,
      y: -1,
      shape: blk,
      orientation: 0
    }
  end

  def next_block do
    %BlockState{
      x: 3,
      y: -1,
      shape: Enum.at(all_shapes, Enum.random(0..6)),
      orientation: 0
    }
  end

  def null_block do
    %BlockState{
      x: 3,
      y: -1,
      shape: :NULL,
      orientation: 0
    }
  end

  defp all_shapes do
    [:I, :T, :O, :J, :L, :S, :Z]
  end

  def all_4x4s do
    %{
      I: [
        [
          [nil, nil, nil, nil],
          [1, 1, 1, 1],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, 1, nil],
          [nil, nil, 1, nil],
          [nil, nil, 1, nil],
          [nil, nil, 1, nil]
        ],
        [
          [nil, nil, nil, nil],
          [nil, nil, nil, nil],
          [1, 1, 1, 1],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, 1, nil, nil]
        ]
      ],
      T: [
        [
          [nil, 1, nil, nil],
          [1, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [nil, 1, 1, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, nil, nil],
          [1, 1, 1, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [1, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ]
      ],
      O: [
        [
          [nil, 1, 1, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, 1, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, 1, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, 1, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ]
      ],
      J: [
        [
          [1, nil, nil, nil],
          [1, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, 1, nil],
          [nil, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, nil, nil],
          [1, 1, 1, nil],
          [nil, nil, 1, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [nil, 1, nil, nil],
          [1, 1, nil, nil],
          [nil, nil, nil, nil]
        ]
      ],
      L: [
        [
          [nil, nil, 1, nil],
          [1, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, nil, nil],
          [1, 1, 1, nil],
          [1, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [1, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ]
      ],
      S: [
        [
          [nil, 1, 1, nil],
          [1, 1, nil, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [nil, 1, 1, nil],
          [nil, nil, 1, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, nil, nil],
          [nil, 1, 1, nil],
          [1, 1, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [1, nil, nil, nil],
          [1, 1, nil, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ]
      ],
      Z: [
        [
          [1, 1, nil, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, 1, nil],
          [nil, 1, 1, nil],
          [nil, 1, nil, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, nil, nil, nil],
          [1, 1, nil, nil],
          [nil, 1, 1, nil],
          [nil, nil, nil, nil]
        ],
        [
          [nil, 1, nil, nil],
          [1, 1, nil, nil],
          [1, nil, nil, nil],
          [nil, nil, nil, nil]
        ]
      ],
      NULL:
        List.duplicate(
          [
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil],
            [nil, nil, nil, nil]
          ],
          4
        )
    }
  end
end
