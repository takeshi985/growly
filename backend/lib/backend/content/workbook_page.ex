defmodule Backend.Content.WorkbookPage do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Content.Lesson
  alias Backend.Content.Workbook

  @target_types ["lesson", "task", "diagnostic", "course"]

  schema "workbook_pages" do
    field :title, :string
    field :page_number, :integer
    field :instructions, :string
    field :qr_code_token, :string
    field :qr_target_type, :string
    field :qr_target_id, :integer
    field :is_published, :boolean, default: false
    belongs_to :workbook, Workbook
    belongs_to :lesson, Lesson
    timestamps(type: :utc_datetime)
  end

  def changeset(page, attrs) do
    page
    |> cast(attrs, [
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
    |> maybe_put_token()
    |> validate_required([
      :workbook_id,
      :title,
      :page_number,
      :instructions,
      :qr_code_token,
      :qr_target_type,
      :is_published
    ])
    |> validate_number(:page_number, greater_than: 0)
    |> validate_inclusion(:qr_target_type, @target_types)
    |> foreign_key_constraint(:workbook_id)
    |> foreign_key_constraint(:lesson_id)
    |> unique_constraint(:qr_code_token)
    |> unique_constraint([:workbook_id, :page_number])
  end

  def target_types, do: @target_types

  defp maybe_put_token(changeset) do
    case get_field(changeset, :qr_code_token) do
      token when is_binary(token) and token != "" -> changeset
      _ -> put_change(changeset, :qr_code_token, generate_token())
    end
  end

  defp generate_token do
    12 |> :crypto.strong_rand_bytes() |> Base.url_encode64(padding: false)
  end
end
