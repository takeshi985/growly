defmodule Backend.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo

  alias Backend.Accounts.Parent

  @doc """
  Returns the list of parents.

  ## Examples

      iex> list_parents()
      [%Parent{}, ...]

  """
  def list_parents do
    Repo.all(Parent)
  end

  @doc """
  Gets a single parent.

  Raises `Ecto.NoResultsError` if the Parent does not exist.

  ## Examples

      iex> get_parent!(123)
      %Parent{}

      iex> get_parent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_parent!(id), do: Repo.get!(Parent, id)

  @doc """
  Creates a parent.

  ## Examples

      iex> create_parent(%{field: value})
      {:ok, %Parent{}}

      iex> create_parent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_parent(attrs) do
    %Parent{}
    |> Parent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a parent.

  ## Examples

      iex> update_parent(parent, %{field: new_value})
      {:ok, %Parent{}}

      iex> update_parent(parent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_parent(%Parent{} = parent, attrs) do
    parent
    |> Parent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a parent.

  ## Examples

      iex> delete_parent(parent)
      {:ok, %Parent{}}

      iex> delete_parent(parent)
      {:error, %Ecto.Changeset{}}

  """
  def delete_parent(%Parent{} = parent) do
    Repo.delete(parent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking parent changes.

  ## Examples

      iex> change_parent(parent)
      %Ecto.Changeset{data: %Parent{}}

  """
  def change_parent(%Parent{} = parent, attrs \\ %{}) do
    Parent.changeset(parent, attrs)
  end
end
