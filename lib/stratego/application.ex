defmodule Stratego.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      StrategoWeb.Telemetry,
      # Start the Ecto repository
      Stratego.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Stratego.PubSub},
      # Start Finch
      {Finch, name: Stratego.Finch},
      # Start the Endpoint (http/https)
      StrategoWeb.Endpoint
      # Start a worker by calling: Stratego.Worker.start_link(arg)
      # {Stratego.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Stratego.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    StrategoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
