defmodule Backend.Content.Unit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Course
  alias Backend.Content.Lesson

  schema "units" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :area, :string
    field :sort_order, :integer, default: 0
    belongs_to :course, Course
    has_many :lessons, Lesson
    timestamps(type: :utc_datetime)
  end

  def changeset(unit, attrs) do
    unit
    |> cast(attrs, [:course_id, :title, :slug, :description, :area, :sort_order])
    |> validate_required([:course_id, :title, :slug, :description, :area, :sort_order])
    |> validate_inclusion(:area, ["math", "reading", "logic"])
    |> validate_number(:sort_order, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:course_id)
    |> unique_constraint([:course_id, :slug])
  end
end
