defmodule Backend.Demo do
  @moduledoc """
  Creates, reuses, and safely resets the deterministic browser demo data.
  """

  import Ecto.Query, warn: false

  alias Backend.Accounts
  alias Backend.Accounts.Parent
  alias Backend.Content
  alias Backend.Content.Skill
  alias Backend.Content.Task
  alias Backend.Learning
  alias Backend.Learning.ChildProfile
  alias Backend.Learning.DiagnosticSession
  alias Backend.Learning.TaskAttempt
  alias Backend.Repo

  @demo_parent_email "demo@growly.local"
  @demo_child_name "Миша"

  @content [
    %{
      area: "math",
      title: "Считает предметы до 10",
      task: %{
        type: "choose_side",
        question: "Где больше яблок?",
        options: %{"left" => "🍎 🍎 🍎", "right" => "🍎 🍎 🍎 🍎 🍎"},
        correct_answer: "right",
        difficulty: 1,
        hint1: "Посчитай яблоки в каждой группе по одному.",
        hint2: "Слева 3 яблока, а справа 5. Какое число больше?",
        explanation: "Справа 5 яблок. Пять больше трёх."
      }
    },
    %{
      area: "math",
      title: "Сравнивает больше и меньше",
      task: %{
        type: "multiple_choice",
        question: "Какое число больше: 7 или 4?",
        options: %{"4" => "4", "7" => "7"},
        correct_answer: "7",
        difficulty: 2,
        hint1: "Представь числовую дорожку: дальше находится большее число.",
        hint2: "После 4 идут 5, 6 и 7.",
        explanation: "Число 7 больше числа 4."
      }
    },
    %{
      area: "math",
      title: "Складывает в пределах 10",
      task: %{
        type: "multiple_choice",
        question: "Сколько всего яблок: 2 и ещё 3?",
        options: %{"4" => "4", "5" => "5", "6" => "6"},
        correct_answer: "5",
        difficulty: 3,
        hint1: "Начни с двух и добавь ещё три: 3, 4...",
        hint2: "Два плюс три — это пять.",
        explanation: "Если к 2 добавить 3, получится 5."
      }
    },
    %{
      area: "reading",
      title: "Узнаёт буквы",
      task: %{
        type: "multiple_choice",
        question: "Выбери букву А",
        options: %{"a" => "А", "m" => "М", "o" => "О"},
        correct_answer: "a",
        difficulty: 1,
        hint1: "У буквы А две наклонные палочки и перекладина.",
        hint2: "Она похожа на домик: А.",
        explanation: "Это буква А."
      }
    },
    %{
      area: "reading",
      title: "Читает простые слоги",
      task: %{
        type: "multiple_choice",
        question: "Какой слог: М + А?",
        options: %{"ma" => "МА", "om" => "ОМ", "ra" => "РА"},
        correct_answer: "ma",
        difficulty: 2,
        hint1: "Сначала произнеси М, затем сразу А.",
        hint2: "Вместе получается МА.",
        explanation: "Буквы М и А вместе образуют слог МА."
      }
    },
    %{
      area: "reading",
      title: "Понимает короткие слова",
      task: %{
        type: "multiple_choice",
        question: "Где слово «кот»?",
        options: %{"cat" => "кот", "home" => "дом", "forest" => "лес"},
        correct_answer: "cat",
        difficulty: 3,
        hint1: "Ищи слово, которое начинается с буквы К.",
        hint2: "Прочитай по звукам: К-О-Т.",
        explanation: "Слово «кот» состоит из букв К, О и Т."
      }
    },
    %{
      area: "logic",
      title: "Находит лишний предмет",
      task: %{
        type: "multiple_choice",
        question: "Что лишнее: яблоко, груша или машина?",
        options: %{"apple" => "🍎 Яблоко", "car" => "🚗 Машина", "pear" => "🍐 Груша"},
        correct_answer: "car",
        difficulty: 1,
        hint1: "Два предмета можно съесть, а один — нет.",
        hint2: "Яблоко и груша — фрукты.",
        explanation: "Машина лишняя: это транспорт, а остальные предметы — фрукты."
      }
    },
    %{
      area: "logic",
      title: "Продолжает последовательность",
      task: %{
        type: "multiple_choice",
        question: "Что дальше: круг, квадрат, круг, квадрат, ...?",
        options: %{"circle" => "● Круг", "square" => "■ Квадрат", "triangle" => "▲ Треугольник"},
        correct_answer: "circle",
        difficulty: 2,
        hint1: "Фигуры чередуются: одна, другая, одна, другая.",
        hint2: "После каждого квадрата появляется круг.",
        explanation: "Следующим будет круг, потому что круг и квадрат чередуются."
      }
    },
    %{
      area: "logic",
      title: "Сравнивает предметы по признаку",
      task: %{
        type: "multiple_choice",
        question: "Что подходит к зиме?",
        options: %{"snow" => "❄️ Снег", "sea" => "🌊 Море", "watermelon" => "🍉 Арбуз"},
        correct_answer: "snow",
        difficulty: 3,
        hint1: "Подумай, что мы часто видим на улице зимой.",
        hint2: "Зимой холодно и выпадает снег.",
        explanation: "Снег подходит к зиме: он выпадает в холодную погоду."
      }
    }
  ]

  @doc "Returns all stable demo records, creating missing content only once."
  def ensure_data do
    with {:ok, parent} <- ensure_parent(),
         {:ok, child} <- ensure_child(parent),
         {:ok, records} <- ensure_content() do
      first = List.first(records)

      {:ok,
       %{
         parent: parent,
         child: child,
         skill: first.skill,
         task: first.task,
         skills: Enum.map(records, & &1.skill),
         tasks: Enum.map(records, & &1.task)
       }}
    end
  end

  @doc "Deletes progress belonging only to the stable demo child."
  def reset_progress do
    with {:ok, demo} <- ensure_data() do
      Repo.transaction(fn ->
        from(attempt in TaskAttempt, where: attempt.child_profile_id == ^demo.child.id)
        |> Repo.delete_all()

        from(session in DiagnosticSession, where: session.child_profile_id == ^demo.child.id)
        |> Repo.delete_all()
      end)

      {:ok, demo}
    end
  end

  defp ensure_parent do
    case Repo.get_by(Parent, email: @demo_parent_email) do
      nil -> Accounts.create_parent(%{email: @demo_parent_email})
      parent -> {:ok, parent}
    end
  end

  defp ensure_child(parent) do
    query =
      from(child in ChildProfile,
        where: child.parent_id == ^parent.id and child.name == ^@demo_child_name,
        limit: 1
      )

    case Repo.one(query) do
      nil ->
        Learning.create_child_profile(%{parent_id: parent.id, name: @demo_child_name, age: 6})

      child ->
        {:ok, child}
    end
  end

  defp ensure_content do
    Enum.reduce_while(@content, {:ok, []}, fn item, {:ok, records} ->
      with {:ok, skill} <- ensure_skill(item),
           {:ok, task} <- ensure_task(skill, item.task) do
        {:cont, {:ok, [%{skill: skill, task: task} | records]}}
      else
        {:error, reason} -> {:halt, {:error, reason}}
      end
    end)
    |> case do
      {:ok, records} -> {:ok, Enum.reverse(records)}
      error -> error
    end
  end

  defp ensure_skill(item) do
    case Repo.get_by(Skill, title: item.title, area: item.area) do
      nil -> Content.create_skill(%{title: item.title, area: item.area, age_min: 5, age_max: 7})
      skill -> {:ok, skill}
    end
  end

  defp ensure_task(skill, attrs) do
    case Repo.get_by(Task, skill_id: skill.id, question: attrs.question) do
      nil -> Content.create_task(Map.put(attrs, :skill_id, skill.id))
      task -> {:ok, task}
    end
  end
end
