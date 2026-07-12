defmodule Backend.Content.Workbook do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.WorkbookPage

  schema "workbooks" do
    field :title, :string
    field :slug, :string
    field :description, :string
    field :age_min, :integer
    field :age_max, :integer
    field :is_published, :boolean, default: false
    field :sort_order, :integer, default: 0
    has_many :pages, WorkbookPage
    timestamps(type: :utc_datetime)
  end

  def changeset(workbook, attrs) do
    workbook
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
    |> unique_constraint(:slug)
  end
end
