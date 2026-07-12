defmodule Backend.Accounts.Parent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parents" do
    field :email, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(parent, attrs) do
    parent
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
