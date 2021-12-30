import Config

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :stratego, Stratego.Repo,
  username: "postgres",
  password: "postgres",
  database: "stratego_test#{System.get_env("MIX_TEST_PARTITION")}",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :stratego, StrategoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "6l2HZHRsVD6r2i+hpjQlGxOtKFD/xUJl5nirh3xplB1b6W3YgUx1mF1HmL8ZgkOn",
  server: false

# In test we don't send emails.
config :stratego, Stratego.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
