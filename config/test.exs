import Config

# Only in tests, remove the complexity from the password hashing algorithm
config :bcrypt_elixir, :log_rounds, 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :social, Social.Repo,
  username: "postgres",
  password: "root123",
  database: "social_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :social, SocialWeb.Endpoint,
  http: [port: 4002],
  server: false

config :social, :avatar_client, Social.Avatar.TestClient

# Print only warnings and errors during test
config :logger, level: :debug

config :social, :cloudinary,
  api_key: 123,
  api_secret: "abc123",
  cloud_name: "demo"
