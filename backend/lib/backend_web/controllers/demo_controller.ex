defmodule BackendWeb.DemoController do
  use BackendWeb, :controller

  alias Backend.Demo
  alias Backend.Learning

  def index(conn, _params) do
    render(conn, :index)
  end

  def child(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data() do
      render_child(conn, demo)
    end
  end

  def answer(conn, %{"answer" => %{"selected_answer" => selected_answer}}) do
    with {:ok, demo} <- Demo.ensure_data(),
         {:ok, task} <- Learning.next_task_for_child(demo.child.id),
         {:ok, answer_result} <-
           Learning.submit_task_answer(demo.child.id, task.id, %{
             selected_answer: selected_answer,
             hint_used: false
           }) do
      render_child(conn, demo, answer_result.feedback, selected_answer)
    else
      {:error, :no_task_available} ->
        with {:ok, demo} <- Demo.ensure_data() do
          render_child(conn, demo, %{message: "Все демо-задания уже пройдены!", action: :complete})
        end

      {:error, %Ecto.Changeset{}} ->
        with {:ok, demo} <- Demo.ensure_data() do
          render_child(conn, demo, %{message: "Выбери один из вариантов, и мы проверим ответ."})
        end
    end
  end

  def answer(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data() do
      render_child(conn, demo, %{message: "Выбери один из вариантов, и мы проверим ответ."})
    end
  end

  def parent(conn, _params) do
    with {:ok, demo} <- Demo.ensure_data(),
         {:ok, progress} <- Learning.progress_for_child(demo.child.id) do
      render(conn, :parent, child: demo.child, progress: progress)
    end
  end

  defp render_child(conn, demo, feedback \\ nil, selected_answer \\ nil) do
    task = next_task(demo.child.id)

    render(conn, :child,
      child: demo.child,
      task: task,
      feedback: feedback,
      form: Phoenix.Component.to_form(%{"selected_answer" => selected_answer}, as: :answer),
      options: task_options(task)
    )
  end

  defp next_task(child_profile_id) do
    case Learning.next_task_for_child(child_profile_id) do
      {:ok, task} -> task
      {:error, :no_task_available} -> nil
    end
  end

  defp task_options(nil), do: []

  defp task_options(task) do
    task.options
    |> Enum.sort_by(fn {side, _count} -> side end)
    |> Enum.map(fn {side, count} -> {side, option_label(side, count)} end)
  end

  defp option_label("left", count), do: "Слева — #{count}"
  defp option_label("right", count), do: "Справа — #{count}"
  defp option_label(_side, count), do: to_string(count)
end
