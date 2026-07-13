defmodule Backend.Learning.PairingSession do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Learning.ChildProfile

  schema "pairing_sessions" do
    field :code, :string
    field :token, :string
    field :expires_at, :utc_datetime
    field :claimed_at, :utc_datetime

    belongs_to :child_profile, ChildProfile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(pairing_session, child_profile_id, attrs) do
    pairing_session
    |> cast(attrs, [:code, :token, :expires_at])
    |> put_change(:child_profile_id, child_profile_id)
    |> validate_required([:child_profile_id, :code, :token, :expires_at])
    |> validate_format(:code, ~r/^\d{8}$/)
    |> validate_length(:token, min: 20)
    |> unique_constraint(:code)
    |> unique_constraint(:token)
    |> foreign_key_constraint(:child_profile_id)
  end

  @doc false
  def claim_changeset(pairing_session, claimed_at) do
    change(pairing_session, claimed_at: claimed_at)
  end
end
