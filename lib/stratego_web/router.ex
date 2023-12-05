defmodule StrategoWeb.Router do
  use StrategoWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {StrategoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :rate_limited do
    plug(StrategoWeb.Plugs.AuthRateLimit, interval_seconds: 10, max_requests: 3)
  end

  # pipeline :rate_limited do
  #   plug(StrategoWeb.Plugs.RateLimit, interval_seconds: 10, max_requests: 3)
  # end

  scope "/", StrategoWeb do
    pipe_through(:browser)
    get("/", HomeController, :home)
    get("/create", HomeController, :create)
    get("/join", HomeController, :join)
    live("/play/:uid", PlayLive)
    live("/error", ErrorLive)
  end

  scope "/", StrategoWeb do
    pipe_through([:browser, :rate_limited])
    post("/create", HomeController, :create_game)
    post("/join", HomeController, :join_game)
  end

  # Other scopes may use custom stacks.
  # scope "/api", StrategoWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:stratego, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: StrategoWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
