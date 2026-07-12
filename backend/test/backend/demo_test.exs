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
    assert Enum.sort(Enum.uniq(Enum.map(first.skills, & &1.area))) == ["logic", "math", "reading"]
    assert length(first.skills) == 9
    assert length(first.tasks) == 9
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
