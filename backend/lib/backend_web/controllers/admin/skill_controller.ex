defmodule BackendWeb.Admin.SkillController do
  use BackendWeb, :controller

  alias Backend.Content
  alias Backend.Content.Skill

  def index(conn, _params) do
    render(conn, :index,
      skills: Content.list_skills_with_tasks(),
      delete_form: Phoenix.Component.to_form(%{}, as: :delete)
    )
  end

  def new(conn, _params) do
    render_form(conn, :new, %Skill{}, Content.change_skill(%Skill{}))
  end

  def create(conn, %{"skill" => skill_params}) do
    case Content.create_skill(skill_params) do
      {:ok, _skill} ->
        conn
        |> put_flash(:info, "Навык создан")
        |> redirect(to: ~p"/admin/content/skills")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_form(:new, %Skill{}, changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    skill = Content.get_skill!(id)
    render_form(conn, :edit, skill, Content.change_skill(skill))
  end

  def update(conn, %{"id" => id, "skill" => skill_params}) do
    skill = Content.get_skill!(id)

    case Content.update_skill(skill, skill_params) do
      {:ok, _skill} ->
        conn
        |> put_flash(:info, "Навык сохранён")
        |> redirect(to: ~p"/admin/content/skills")

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render_form(:edit, skill, changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    skill = Content.get_skill!(id)

    if Content.count_tasks_for_skill(skill.id) > 0 do
      conn
      |> put_flash(:error, "Сначала удалите задания, связанные с этим навыком")
      |> redirect(to: ~p"/admin/content/skills")
    else
      {:ok, _skill} = Content.delete_skill(skill)

      conn
      |> put_flash(:info, "Навык удалён")
      |> redirect(to: ~p"/admin/content/skills")
    end
  end

  defp render_form(conn, action, skill, changeset) do
    render(conn, :editor,
      action: action,
      skill: skill,
      form: Phoenix.Component.to_form(changeset)
    )
  end
end
