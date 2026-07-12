defmodule BackendWeb.Admin.TaskController do
  use BackendWeb, :controller

  alias Backend.Content
  alias Backend.Content.Options
  alias Backend.Content.Task

  def index(conn, _params) do
    render(conn, :index,
      tasks: Content.list_tasks_with_skills(),
      delete_form: Phoenix.Component.to_form(%{}, as: :delete)
    )
  end

  def new(conn, _params) do
    task = %Task{}
    render_form(conn, :new, task, Content.change_task(task))
  end

  def create(conn, %{"task" => task_params}) do
    with {:ok, attrs} <- parse_options(%Task{}, task_params),
         {:ok, _task} <- Content.create_task(attrs) do
      conn
      |> put_flash(:info, "Задание создано")
      |> redirect(to: ~p"/admin/content/tasks")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_form(:new, %Task{}, changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    task = Content.get_task!(id)
    changeset = Content.change_task(task, %{options_text: Options.format(task.options)})
    render_form(conn, :edit, task, changeset)
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = Content.get_task!(id)

    with {:ok, attrs} <- parse_options(task, task_params),
         {:ok, _task} <- Content.update_task(task, attrs) do
      conn
      |> put_flash(:info, "Задание сохранено")
      |> redirect(to: ~p"/admin/content/tasks")
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_form(:edit, task, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    task = Content.get_task!(id)

    try do
      {:ok, _task} = Content.delete_task(task)

      conn
      |> put_flash(:info, "Задание удалено")
      |> redirect(to: ~p"/admin/content/tasks")
    rescue
      Ecto.ConstraintError ->
        conn
        |> put_flash(:error, "Нельзя удалить задание, для которого уже сохранены ответы")
        |> redirect(to: ~p"/admin/content/tasks")
    end
  end

  defp parse_options(task, task_params) do
    case Options.parse(task_params["options_text"]) do
      {:ok, options} ->
        {:ok, Map.put(task_params, "options", options)}

      {:error, message} ->
        changeset =
          task
          |> Content.change_task(task_params)
          |> Ecto.Changeset.add_error(:options_text, message)

        changeset = %{changeset | action: if(task.id, do: :update, else: :insert)}

        {:error, changeset}
    end
  end

  defp render_form(conn, action, task, changeset) do
    skills = Content.list_skills_with_tasks()

    render(conn, :editor,
      action: action,
      task: task,
      form: Phoenix.Component.to_form(changeset),
      skill_options: Enum.map(skills, &{"#{area_label(&1.area)} · #{&1.title}", &1.id})
    )
  end

  defp area_label("math"), do: "Счёт"
  defp area_label("reading"), do: "Чтение"
  defp area_label("logic"), do: "Логика"
  defp area_label(area), do: area
end
