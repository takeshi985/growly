defmodule BackendWeb.DemoController do
  use BackendWeb, :controller

  alias Backend.Demo
  alias Backend.Learning

  def index(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data() do
      render(conn, :index, child: demo.child)
    end
  end

  def child(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data() do
      render_child(conn, demo)
    end
  end

  def answer(conn, %{"answer" => %{"selected_answer" => selected_answer} = params}) do
    task_id = params["task_id"]

    with {:ok, demo} <- Demo.ensure_data(),
         {:ok, current_task} <- Learning.next_task_for_child(demo.child.id),
         true <- is_nil(task_id) or to_string(current_task.id) == to_string(task_id),
         {:ok, answer_result} <-
           Learning.submit_task_answer(demo.child.id, current_task.id, %{
             selected_answer: selected_answer,
             hint_used: params["hint_used"] == "true"
           }) do
      render_child(conn, demo, answer_result.feedback, selected_answer)
    else
      {:error, :no_task_available} -> render_completed_child(conn)
      false -> redirect(conn, to: ~p"/demo/child")
      {:error, %Ecto.Changeset{}} -> render_answer_error(conn)
    end
  end

  def answer(conn, _params), do: render_answer_error(conn)

  def parent(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data(),
         {:ok, progress} <- Learning.progress_for_child(demo.child.id) do
      render(conn, :parent, child: demo.child, progress: progress)
    end
  end

  def reset(conn, _params) do
    with {:ok, _demo} <- Demo.reset_progress() do
      conn
      |> put_flash(:info, "Демо-прогресс Миши сброшен. Можно начать заново.")
      |> redirect(to: ~p"/demo")
    end
  end

  def diagnostic(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data() do
      render(conn, :diagnostic,
        child: demo.child,
        diagnostic: nil,
        task: nil,
        result: nil,
        form: nil,
        options: []
      )
    end
  end

  def start_diagnostic(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data(),
         {:ok, %{session: session, task: task}} <- Learning.start_diagnostic(demo.child.id) do
      render_diagnostic_task(conn, demo.child, session, task)
    end
  end

  def answer_diagnostic(conn, %{
        "diagnostic" => %{
          "session_id" => session_id,
          "task_id" => task_id,
          "selected_answer" => selected_answer
        }
      }) do
    with {:ok, demo} <- Demo.ensure_data(),
         {:ok, diagnostic} <-
           Learning.submit_diagnostic_answer(session_id, task_id, %{
             selected_answer: selected_answer
           }) do
      if diagnostic.completed do
        render(conn, :diagnostic,
          child: demo.child,
          diagnostic: diagnostic,
          task: nil,
          result: diagnostic.result,
          form: nil,
          options: []
        )
      else
        render_diagnostic_task(conn, demo.child, diagnostic.session, diagnostic.next_task)
      end
    else
      {:error, reason}
      when reason in [
             :diagnostic_session_not_found,
             :diagnostic_completed,
             :unexpected_diagnostic_task
           ] ->
        conn
        |> put_flash(:error, "Диагностическая сессия устарела. Начните её ещё раз.")
        |> redirect(to: ~p"/demo/diagnostic")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Выберите один вариант ответа.")
        |> redirect(to: ~p"/demo/diagnostic")
    end
  end

  def answer_diagnostic(conn, _params) do
    conn
    |> put_flash(:error, "Выберите один вариант ответа.")
    |> redirect(to: ~p"/demo/diagnostic")
  end

  defp render_child(conn, demo, feedback \\ nil, selected_answer \\ nil) do
    {:ok, session} = Learning.learning_session_for_child(demo.child.id)
    task = session.next_task
    skill = if task, do: task.skill
    hint_used = feedback && feedback.action in [:show_hint1, :show_hint2]

    render(conn, :child,
      child: demo.child,
      task: task,
      skill: skill,
      feedback: feedback,
      form:
        Phoenix.Component.to_form(
          %{
            "selected_answer" => selected_answer,
            "task_id" => task && task.id,
            "hint_used" => to_string(hint_used || false)
          },
          as: :answer
        ),
      options: task_options(task)
    )
  end

  defp render_completed_child(conn) do
    with {:ok, demo} <- Demo.ensure_data() do
      render_child(conn, demo, %{message: "Все задания на сегодня пройдены!", action: :complete})
    end
  end

  defp render_answer_error(conn) do
    with {:ok, demo} <- Demo.ensure_data() do
      render_child(conn, demo, %{
        message: "Выбери один из вариантов — я подожду.",
        action: :choose_answer
      })
    end
  end

  defp render_diagnostic_task(conn, child, session, %{task: task, area: area} = diagnostic_task) do
    render(conn, :diagnostic,
      child: child,
      diagnostic: %{session: session, area: area},
      task: diagnostic_task,
      result: nil,
      form:
        Phoenix.Component.to_form(
          %{
            "session_id" => session.id,
            "task_id" => task.id,
            "selected_answer" => nil
          },
          as: :diagnostic
        ),
      options: task_options(task)
    )
  end

  defp task_options(nil), do: []

  defp task_options(task) do
    task.options
    |> Enum.sort_by(fn {value, _label} -> value end)
    |> Enum.map(fn {value, label} -> {value, to_string(label)} end)
  end
end
