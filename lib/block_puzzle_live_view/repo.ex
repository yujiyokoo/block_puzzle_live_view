defmodule BlockPuzzleLiveView.Repo do
  use Ecto.Repo,
    otp_app: :block_puzzle_live_view,
    adapter: Ecto.Adapters.Postgres
end
