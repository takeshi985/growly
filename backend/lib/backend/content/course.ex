defmodule Backend.Content.Course do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Unit

  schema "courses" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :age_min, :integer
    field :age_max, :integer
    field :is_published, :boolean, default: false
    field :sort_order, :integer, default: 0
    has_many :units, Unit
    timestamps(type: :utc_datetime)
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:title, :slug, :description, :age_min, :age_max, :is_published, :sort_order])
    |> validate_required([
      :title,
      :slug,
      :description,
      :age_min,
      :age_max,
      :is_published,
      :sort_order
    ])
    |> validate_number(:age_min, greater_than: 0)
    |> validate_number(:age_max, greater_than: 0)
    |> validate_number(:sort_order, greater_than_or_equal_to: 0)
    |> validate_age_range()
    |> unique_constraint(:slug)
  end

  defp validate_age_range(changeset) do
    age_min = get_field(changeset, :age_min)
    age_max = get_field(changeset, :age_max)

    if age_min && age_max && age_min > age_max,
      do: add_error(changeset, :age_max, "must be greater than or equal to age_min"),
      else: changeset
  end
end
