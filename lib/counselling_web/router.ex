defmodule CounsellingWeb.Router do
  use CounsellingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {CounsellingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CounsellingWeb do
    pipe_through :browser

    live "/colleges", CollegeLive.Index, :index
    live "/colleges/new", CollegeLive.Index, :new
    live "/colleges/:id/edit", CollegeLive.Index, :edit

    live "/colleges/:slug", CollegeLive.Show, :show
    live "/colleges/:id/Programs", CollegeLive.Show, :show
    live "/colleges/:id/show/edit", CollegeLive.Show, :edit

    live "/programs", ProgramLive.Index, :index
    live "/programs/:slug", ProgramLive.Show, :show
    live "/colleges/:slug/:slug", CollegeProgramLive.Show, :show
    live "/IIT", ProgramLive.Index, :index
    live "/NIT", ProgramLive.Index, :index
    live "/IIIT", ProgramLive.Index, :index
    live "/GFTI", ProgramLive.Index, :index

    # live "/colleges/:id/branch/:id", CollegeLive.Show, :show

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", CounsellingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:counselling, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: CounsellingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
