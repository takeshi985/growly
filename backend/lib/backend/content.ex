defmodule Backend.Content do
  @moduledoc """
  The Content context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Content.Skill

  @doc """
  Returns the list of skills.

  ## Examples

      iex> list_skills()
      [%Skill{}, ...]

  """
  def list_skills do
    Repo.all(Skill)
  end

  @doc "Returns skills ordered for the admin UI with their tasks preloaded."
  def list_skills_with_tasks do
    from(skill in Skill, order_by: [asc: skill.area, asc: skill.title])
    |> Repo.all()
    |> Repo.preload(:tasks)
  end

  @doc """
  Gets a single skill.

  Raises `Ecto.NoResultsError` if the Skill does not exist.

  ## Examples

      iex> get_skill!(123)
      %Skill{}

      iex> get_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill!(id), do: Repo.get!(Skill, id)

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs) do
    %Skill{}
    |> Skill.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill.

  ## Examples

      iex> delete_skill(skill)
      {:ok, %Skill{}}

      iex> delete_skill(skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill(%Skill{} = skill) do
    Repo.delete(skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{data: %Skill{}}

  """
  def change_skill(%Skill{} = skill, attrs \\ %{}) do
    Skill.changeset(skill, attrs)
  end

  alias Backend.Content.Task

  @doc """
  Returns the list of tasks.

  ## Examples

      iex> list_tasks()
      [%Task{}, ...]

  """
  def list_tasks do
    Repo.all(Task)
  end

  @doc "Returns tasks ordered for the admin UI with their skill preloaded."
  def list_tasks_with_skills do
    from(task in Task,
      join: skill in assoc(task, :skill),
      order_by: [asc: skill.area, asc: skill.title, asc: task.difficulty, asc: task.id],
      preload: [:lesson, skill: skill]
    )
    |> Repo.all()
  end

  @doc "Returns compact content totals for the internal admin homepage."
  def content_summary do
    area_counts =
      from(skill in Skill, group_by: skill.area, select: {skill.area, count(skill.id)})
      |> Repo.all()
      |> Map.new()

    %{
      total_skills: Repo.aggregate(Skill, :count),
      total_tasks: Repo.aggregate(Task, :count),
      math_skills: Map.get(area_counts, "math", 0),
      reading_skills: Map.get(area_counts, "reading", 0),
      logic_skills: Map.get(area_counts, "logic", 0)
    }
  end

  @doc "Counts tasks linked to one skill."
  def count_tasks_for_skill(skill_id) do
    from(task in Task, where: task.skill_id == ^skill_id)
    |> Repo.aggregate(:count)
  end

  @doc """
  Gets a single task.

  Raises `Ecto.NoResultsError` if the Task does not exist.

  ## Examples

      iex> get_task!(123)
      %Task{}

      iex> get_task!(456)
      ** (Ecto.NoResultsError)

  """
  def get_task!(id), do: Repo.get!(Task, id)

  @doc """
  Creates a task.

  ## Examples

      iex> create_task(%{field: value})
      {:ok, %Task{}}

      iex> create_task(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_task(attrs) do
    %Task{}
    |> Task.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a task.

  ## Examples

      iex> update_task(task, %{field: new_value})
      {:ok, %Task{}}

      iex> update_task(task, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_task(%Task{} = task, attrs) do
    task
    |> Task.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a task.

  ## Examples

      iex> delete_task(task)
      {:ok, %Task{}}

      iex> delete_task(task)
      {:error, %Ecto.Changeset{}}

  """
  def delete_task(%Task{} = task) do
    Repo.delete(task)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking task changes.

  ## Examples

      iex> change_task(task)
      %Ecto.Changeset{data: %Task{}}

  """
  def change_task(%Task{} = task, attrs \\ %{}) do
    Task.changeset(task, attrs)
  end

  # Curriculum
  alias Backend.Content.Course
  alias Backend.Content.Lesson
  alias Backend.Content.Unit
  alias Backend.Content.Workbook
  alias Backend.Content.WorkbookPage

  def list_courses, do: Repo.all(from course in Course, order_by: [course.sort_order, course.id])

  def list_published_courses do
    Repo.all(
      from course in Course, where: course.is_published, order_by: [course.sort_order, course.id]
    )
  end

  def list_published_courses_with_curriculum do
    list_published_courses()
    |> Repo.preload(
      units:
        {from(unit in Unit, order_by: [unit.sort_order, unit.id]),
         lessons:
           {from(lesson in Lesson,
              where: lesson.is_published,
              order_by: [lesson.sort_order, lesson.id]
            ), [:skill, :tasks]}}
    )
  end

  def get_course!(id), do: Repo.get!(Course, id)

  def get_course_with_curriculum!(id) do
    Course
    |> Repo.get!(id)
    |> Repo.preload(
      units:
        {from(unit in Unit, order_by: [unit.sort_order, unit.id]),
         lessons:
           {from(lesson in Lesson, order_by: [lesson.sort_order, lesson.id]), [:skill, :tasks]}}
    )
  end

  def get_published_course_with_curriculum!(id) do
    Course
    |> Repo.get_by!(id: id, is_published: true)
    |> Repo.preload(
      units:
        {from(unit in Unit, order_by: [unit.sort_order, unit.id]),
         lessons:
           {from(lesson in Lesson,
              where: lesson.is_published,
              order_by: [lesson.sort_order, lesson.id]
            ), [:skill, :tasks]}}
    )
  end

  def create_course(attrs), do: %Course{} |> Course.changeset(attrs) |> Repo.insert()

  def update_course(%Course{} = course, attrs),
    do: course |> Course.changeset(attrs) |> Repo.update()

  def delete_course(%Course{} = course), do: Repo.delete(course)
  def change_course(%Course{} = course, attrs \\ %{}), do: Course.changeset(course, attrs)

  def list_units do
    Repo.all(
      from unit in Unit, order_by: [unit.sort_order, unit.id], preload: [:course, :lessons]
    )
  end

  def list_units_for_course(course_id) do
    Repo.all(
      from unit in Unit, where: unit.course_id == ^course_id, order_by: [unit.sort_order, unit.id]
    )
  end

  def get_unit!(id), do: Repo.get!(Unit, id)
  def create_unit(attrs), do: %Unit{} |> Unit.changeset(attrs) |> Repo.insert()
  def update_unit(%Unit{} = unit, attrs), do: unit |> Unit.changeset(attrs) |> Repo.update()
  def delete_unit(%Unit{} = unit), do: Repo.delete(unit)
  def change_unit(%Unit{} = unit, attrs \\ %{}), do: Unit.changeset(unit, attrs)

  def list_lessons do
    Repo.all(
      from lesson in Lesson,
        order_by: [lesson.sort_order, lesson.id],
        preload: [:unit, :skill, :tasks]
    )
  end

  def list_lessons_for_unit(unit_id) do
    Repo.all(
      from lesson in Lesson,
        where: lesson.unit_id == ^unit_id,
        order_by: [lesson.sort_order, lesson.id]
    )
  end

  def get_lesson!(id), do: Repo.get!(Lesson, id)

  def get_lesson_with_content!(id),
    do: Lesson |> Repo.get!(id) |> Repo.preload([:skill, :tasks, unit: :course])

  def create_lesson(attrs), do: %Lesson{} |> Lesson.changeset(attrs) |> Repo.insert()

  def update_lesson(%Lesson{} = lesson, attrs),
    do: lesson |> Lesson.changeset(attrs) |> Repo.update()

  def delete_lesson(%Lesson{} = lesson), do: Repo.delete(lesson)
  def change_lesson(%Lesson{} = lesson, attrs \\ %{}), do: Lesson.changeset(lesson, attrs)

  # Workbooks and QR pages
  def list_workbooks do
    Repo.all(
      from workbook in Workbook, order_by: [workbook.sort_order, workbook.id], preload: [:pages]
    )
  end

  def get_workbook!(id), do: Repo.get!(Workbook, id)
  def create_workbook(attrs), do: %Workbook{} |> Workbook.changeset(attrs) |> Repo.insert()

  def update_workbook(%Workbook{} = workbook, attrs),
    do: workbook |> Workbook.changeset(attrs) |> Repo.update()

  def delete_workbook(%Workbook{} = workbook), do: Repo.delete(workbook)

  def change_workbook(%Workbook{} = workbook, attrs \\ %{}),
    do: Workbook.changeset(workbook, attrs)

  def list_workbook_pages do
    Repo.all(
      from page in WorkbookPage,
        order_by: [page.workbook_id, page.page_number],
        preload: [:workbook, lesson: :unit]
    )
  end

  def get_workbook_page!(id), do: Repo.get!(WorkbookPage, id)

  def get_workbook_page_by_token(token) do
    case Repo.get_by(WorkbookPage, qr_code_token: token) do
      nil -> {:error, :not_found}
      page -> {:ok, Repo.preload(page, [:workbook, lesson: :unit])}
    end
  end

  def create_workbook_page(attrs),
    do: %WorkbookPage{} |> WorkbookPage.changeset(attrs) |> Repo.insert()

  def update_workbook_page(%WorkbookPage{} = page, attrs),
    do: page |> WorkbookPage.changeset(attrs) |> Repo.update()

  def delete_workbook_page(%WorkbookPage{} = page), do: Repo.delete(page)

  def change_workbook_page(%WorkbookPage{} = page, attrs \\ %{}),
    do: WorkbookPage.changeset(page, attrs)

  def export_content_pack do
    %{
      version: 1,
      courses:
        Enum.map(
          list_courses(),
          &Map.take(&1, [
            :title,
            :slug,
            :description,
            :age_min,
            :age_max,
            :is_published,
            :sort_order
          ])
        ),
      units:
        Enum.map(
          list_units(),
          &Map.take(&1, [:course_id, :title, :slug, :description, :area, :sort_order])
        ),
      lessons:
        Enum.map(
          list_lessons(),
          &Map.take(&1, [
            :unit_id,
            :skill_id,
            :title,
            :slug,
            :objective,
            :explanation,
            :sort_order,
            :is_published
          ])
        ),
      skills: Enum.map(list_skills(), &Map.take(&1, [:title, :area, :age_min, :age_max])),
      tasks:
        Enum.map(
          list_tasks(),
          &Map.take(&1, [
            :skill_id,
            :lesson_id,
            :type,
            :question,
            :options,
            :correct_answer,
            :difficulty,
            :hint1,
            :hint2,
            :explanation,
            :position
          ])
        ),
      workbooks:
        Enum.map(
          list_workbooks(),
          &Map.take(&1, [
            :title,
            :slug,
            :description,
            :age_min,
            :age_max,
            :is_published,
            :sort_order
          ])
        ),
      workbook_pages:
        Enum.map(
          list_workbook_pages(),
          &Map.take(&1, [
            :workbook_id,
            :lesson_id,
            :title,
            :page_number,
            :instructions,
            :qr_code_token,
            :qr_target_type,
            :qr_target_id,
            :is_published
          ])
        )
    }
  end
end
