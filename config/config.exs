# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :social,
  ecto_repos: [Social.Repo]

# Configures the endpoint
config :social, SocialWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "0BpNGFIKBkLfjGcpAmiOJGauUx0o4pGcGE7Cb76fAjqg5aNv2SN7Aal8O0Il3qAJ",
  render_errors: [view: SocialWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Social.PubSub,
  live_view: [signing_salt: "Y2oVN5US"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :social, :avatar_client, Social.Avatar.Gravatar

config :social, :cloudinary,
  api_key: System.get_env("CLOUDINARY_API_KEY"),
  api_secret: System.get_env("CLOUDINARY_API_SECRET"),
  cloud_name: System.get_env("CLOUDINARY_CLOUD_NAME")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
