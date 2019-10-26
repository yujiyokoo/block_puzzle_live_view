defmodule InputState do
  defstruct left: %{pressed: false, count: 0},
            right: %{pressed: false, count: 0},
            up: %{pressed: false, count: 0},
            down: %{pressed: false, count: 0},
            x: %{pressed: false, count: 0},
            z: %{pressed: false, count: 0}
end
