defmodule BackendWeb.Router do
  use BackendWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {BackendWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BackendWeb do
    pipe_through(:browser)

    get("/", PageController, :home)
    get("/demo", DemoController, :index)
    get("/demo/child", DemoController, :child)
    post("/demo/child/answer", DemoController, :answer)
    get("/demo/parent", DemoController, :parent)
    post("/demo/reset", DemoController, :reset)
    get("/demo/diagnostic", DemoController, :diagnostic)
    post("/demo/diagnostic/start", DemoController, :start_diagnostic)
    post("/demo/diagnostic/answer", DemoController, :answer_diagnostic)
    get("/admin/api-docs", Admin.ApiDocsController, :index)
  end

  scope "/admin/content", BackendWeb.Admin do
    pipe_through(:browser)

    get("/", ContentController, :index)
    resources("/skills", SkillController, except: [:show])
    resources("/tasks", TaskController, except: [:show])
  end

  # Other scopes may use custom stacks.
  scope "/api", BackendWeb do
    pipe_through(:api)

    resources("/parents", ParentController, except: [:new, :edit])
    resources("/child_profiles", ChildProfileController, except: [:new, :edit])
    resources("/skills", SkillController, except: [:new, :edit])
    resources("/tasks", TaskController, except: [:new, :edit])
    resources("/task_attempts", TaskAttemptController, except: [:new, :edit])

    get("/children/:child_id/next_task", ChildNextTaskController, :show)
    get("/children/:child_id/progress", ChildProgressController, :show)
    post("/children/:child_id/diagnostic_sessions", ChildDiagnosticController, :create)
    post("/diagnostic_sessions/:session_id/answers", DiagnosticAnswerController, :create)
    post("/children/:child_id/tasks/:task_id/answer", ChildTaskAnswerController, :create)
  end

  scope "/api/mobile/v1", BackendWeb do
    pipe_through(:api)

    get("/children/:child_id/session", MobileV1Controller, :session)
    post("/children/:child_id/tasks/:task_id/answer", MobileV1Controller, :answer)
    get("/children/:child_id/progress", MobileV1Controller, :progress)
    post("/children/:child_id/diagnostic/start", MobileV1Controller, :start_diagnostic)

    post(
      "/diagnostic_sessions/:session_id/tasks/:task_id/answer",
      MobileV1Controller,
      :diagnostic_answer
    )
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      live_dashboard("/dashboard", metrics: BackendWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
