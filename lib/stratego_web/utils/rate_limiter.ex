defmodule StrategoWeb.Utils.RateLimiter do
  import Phoenix.Controller, only: [json: 2]
  import Plug.Conn, only: [put_status: 2]

  def rate_limit(conn, options \\ []) do
    case check_rate(conn, options) do
      {:ok, _count} -> conn
      {:error, _count} -> render_error(conn)
    end
  end

  def check_rate(conn, options) do
    interval_milliseconds = options[:interval_seconds] * 1000
    max_requests = options[:max_requests]
    bucket_name = options[:bucket_name] || bucket_name(conn)

    ExRated.check_rate(bucket_name, interval_milliseconds, max_requests)
  end

  defp bucket_name(conn) do
    path = Enum.join(conn.path_info, "/")
    ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
    "#{ip}:#{path}"
  end

  defp render_error(conn) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "Rate limit exceeded."})
    |> Plug.Conn.halt()
  end
end
