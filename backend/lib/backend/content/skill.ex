defmodule Backend.Content.Skill do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Task

  schema "skills" do
    field :title, :string
    field :area, :string
    field :age_min, :integer
    field :age_max, :integer

    has_many :tasks, Task

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:title, :area, :age_min, :age_max])
    |> validate_required([:title, :area, :age_min, :age_max])
  end
end
