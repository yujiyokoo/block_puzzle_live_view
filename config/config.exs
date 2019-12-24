# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :block_puzzle_live_view, BlockPuzzleLiveViewWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "4AAOQ+evn//xx3GNUY/uW4AfpRWymMuioZ/3QYzBy1STrKXKz+aU1AwafJjDhQw7",
  render_errors: [view: BlockPuzzleLiveViewWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: BlockPuzzleLiveView.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
     signing_salt: "i3cB6LScWTyTGrliuU4YKKJwyOAK6Awj"
   ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
