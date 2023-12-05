defmodule StrategoWeb.Plugs.AuthRateLimit do
  def init(options) do
    options
  end

  def call(conn, options \\ [])

  def call(%{params: %{"user" => %{"email" => email}}} = conn, options) do
    options = options ++ [bucket_name: "authorization:" <> email]
    StrategoWeb.Utils.RateLimiter.rate_limit(conn, options)
  end

  def call(conn, options) do
    StrategoWeb.Utils.RateLimiter.rate_limit(conn, options)
  end
end
