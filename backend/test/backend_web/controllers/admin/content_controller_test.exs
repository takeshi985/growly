defmodule BackendWeb.Admin.ContentControllerTest do
  use BackendWeb.ConnCase

  alias Backend.Content

  import Backend.ContentFixtures

  test "GET /admin/content renders the internal content homepage", %{conn: conn} do
    document = conn |> get(~p"/admin/content") |> document()

    assert LazyHTML.text(LazyHTML.query_by_id(document, "content-admin-heading")) =~
             "Growly Content Admin"

    assert Enum.count(LazyHTML.query(document, "#content-admin-summary")) == 1
  end

  test "GET /admin/content/skills renders skills", %{conn: conn} do
    skill = skill_fixture(%{title: "Считает до десяти", area: "math", age_min: 5, age_max: 7})
    document = conn |> get(~p"/admin/content/skills") |> document()

    assert LazyHTML.text(LazyHTML.query_by_id(document, "admin-skill-#{skill.id}")) =~ skill.title
  end

  test "creates, edits, and deletes a skill", %{conn: conn} do
    create_conn =
      post(conn, ~p"/admin/content/skills",
        skill: %{title: "Новый навык", area: "logic", age_min: 5, age_max: 7}
      )

    assert redirected_to(create_conn) == ~p"/admin/content/skills"
    skill = Enum.find(Content.list_skills(), &(&1.title == "Новый навык"))
    assert skill.area == "logic"

    update_conn =
      put(conn, ~p"/admin/content/skills/#{skill}",
        skill: %{title: "Обновлённый навык", area: "reading", age_min: 6, age_max: 7}
      )

    assert redirected_to(update_conn) == ~p"/admin/content/skills"
    assert Content.get_skill!(skill.id).title == "Обновлённый навык"

    delete_conn = delete(conn, ~p"/admin/content/skills/#{skill}")
    assert redirected_to(delete_conn) == ~p"/admin/content/skills"
    assert_raise Ecto.NoResultsError, fn -> Content.get_skill!(skill.id) end
  end

  test "GET /admin/content/tasks renders tasks with their skills", %{conn: conn} do
    skill = skill_fixture(%{title: "Логические ряды", area: "logic"})
    task = task_fixture(%{skill: skill, question: "Что идёт дальше?"})
    document = conn |> get(~p"/admin/content/tasks") |> document()

    task_card = LazyHTML.text(LazyHTML.query_by_id(document, "admin-task-#{task.id}"))
    assert task_card =~ task.question
    assert task_card =~ skill.title
  end

  test "creates a task and converts options text into a map", %{conn: conn} do
    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})

    create_conn = post(conn, ~p"/admin/content/tasks", task: task_params(skill.id))

    assert redirected_to(create_conn) == ~p"/admin/content/tasks"
    task = Enum.find(Content.list_tasks(), &(&1.question == "Где больше?"))
    assert task.options == %{"left" => "3", "right" => "5"}
    assert task.correct_answer == "right"
  end

  test "edits and deletes a task", %{conn: conn} do
    skill = skill_fixture(%{area: "math", age_min: 5, age_max: 7})
    task = task_fixture(%{skill: skill, question: "Старый вопрос"})

    attrs =
      skill.id
      |> task_params()
      |> Map.put(:question, "Новый вопрос")
      |> Map.put(:options_text, "a=один\nb=два")
      |> Map.put(:correct_answer, "b")

    update_conn = put(conn, ~p"/admin/content/tasks/#{task}", task: attrs)
    assert redirected_to(update_conn) == ~p"/admin/content/tasks"

    updated_task = Content.get_task!(task.id)
    assert updated_task.question == "Новый вопрос"
    assert updated_task.options == %{"a" => "один", "b" => "два"}

    delete_conn = delete(conn, ~p"/admin/content/tasks/#{task}")
    assert redirected_to(delete_conn) == ~p"/admin/content/tasks"
    assert_raise Ecto.NoResultsError, fn -> Content.get_task!(task.id) end
  end

  test "invalid options text returns validation errors", %{conn: conn} do
    skill = skill_fixture()
    attrs = Map.put(task_params(skill.id), :options_text, "invalid line")

    document =
      conn
      |> post(~p"/admin/content/tasks", task: attrs)
      |> html_response(422)
      |> LazyHTML.from_document()

    assert LazyHTML.text(LazyHTML.query_by_id(document, "admin-task-form")) =~ "формате key=value"
  end

  defp task_params(skill_id) do
    %{
      skill_id: skill_id,
      type: "choose_side",
      question: "Где больше?",
      options_text: "left=3\nright=5",
      correct_answer: "right",
      difficulty: 1,
      hint1: "Посчитай слева",
      hint2: "Слева 3, справа 5",
      explanation: "Пять больше трёх"
    }
  end

  defp document(conn) do
    conn
    |> html_response(200)
    |> LazyHTML.from_document()
  end
end
