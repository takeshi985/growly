defmodule Backend.Learning.ChildProfile do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Accounts.Parent
  alias Backend.Learning.PairingSession

  schema "child_profiles" do
    field(:name, :string)
    field(:age, :integer)

    belongs_to(:parent, Parent)
    has_many(:pairing_sessions, PairingSession)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(child_profile, attrs) do
    child_profile
    |> cast(attrs, [:parent_id, :name, :age])
    |> validate_required([:parent_id, :name, :age])
    |> validate_number(:age, greater_than_or_equal_to: 3, less_than_or_equal_to: 12)
    |> foreign_key_constraint(:parent_id)
  end
end
