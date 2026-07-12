defmodule Backend.DemoTest do
  use Backend.DataCase

  alias Backend.Demo
  alias Backend.Learning
  alias Backend.Learning.DiagnosticSession
  alias Backend.Learning.TaskAttempt
  alias Backend.Repo

  test "ensure_data/0 is idempotent and creates all three learning areas" do
    assert {:ok, first} = Demo.ensure_data()
    assert {:ok, second} = Demo.ensure_data()

    assert second.parent.id == first.parent.id
    assert second.child.id == first.child.id
    assert Enum.map(second.skills, & &1.id) == Enum.map(first.skills, & &1.id)
    assert Enum.map(second.tasks, & &1.id) == Enum.map(first.tasks, & &1.id)
    assert second.course.id == first.course.id
    assert second.workbook.id == first.workbook.id

    assert Enum.map(second.workbook_pages, & &1.id) ==
             Enum.map(first.workbook_pages, & &1.id)

    assert Enum.sort(Enum.uniq(Enum.map(first.skills, & &1.area))) == ["logic", "math", "reading"]
    assert first.parent.email == "demo-parent@growly.local"
    assert length(first.skills) == 12
    assert length(first.tasks) == 12
    assert first.course.slug == "school-readiness-5-7"
    assert length(first.units) == 3
    assert length(first.lessons) == 4
    assert first.workbook.slug == "growly-first-steps"
    assert length(first.workbook_pages) == 3
    assert Enum.all?(first.workbook_pages, &is_binary(&1.qr_code_token))
  end

  test "reset_progress/0 deletes only the demo child's learning progress" do
    assert {:ok, demo} = Demo.ensure_data()

    assert {:ok, _answer} =
             Learning.submit_task_answer(demo.child.id, demo.task.id, %{selected_answer: "left"})

    assert {:ok, %{session: session}} = Learning.start_diagnostic(demo.child.id)
    assert Repo.aggregate(TaskAttempt, :count) == 1
    assert Repo.get(DiagnosticSession, session.id)

    assert {:ok, reset_demo} = Demo.reset_progress()
    assert reset_demo.child.id == demo.child.id
    assert Repo.aggregate(TaskAttempt, :count) == 0
    refute Repo.get(DiagnosticSession, session.id)
  end
end
