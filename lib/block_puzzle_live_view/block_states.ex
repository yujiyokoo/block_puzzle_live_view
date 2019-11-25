defmodule BlockPuzzleLiveView.BlockStates do
  alias BlockPuzzleLiveView.BlockState

  def as_4x4(block_state) do
    Enum.at(all_4x4s[block_state.shape], block_state.orientation)
  end

  def clockwise_next(block_state) do
    %{block_state | orientation: rem(block_state.orientation + 1, 4)}
  end

  def counterclockwise_next(block_state) do
    %{block_state | orientation: rem(block_state.orientation + 3, 4)}
  end

  def colour(shape) do
    %{I: :cyan, O: :yellow, L: :orange, J: :blue, S: :green, Z: :red, T: :purple, NULL: :none}[
      shape
    ]
  end

  def random_block do
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
