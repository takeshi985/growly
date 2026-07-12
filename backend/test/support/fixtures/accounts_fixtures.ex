defmodule Backend.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Backend.Accounts` context.
  """

  @doc """
  Generate a parent.
  """
  def parent_fixture(attrs \\ %{}) do
    unique = System.unique_integer([:positive])

    {:ok, parent} =
      attrs
      |> Enum.into(%{
        email: "parent#{unique}@growly.test"
      })
      |> Backend.Accounts.create_parent()

    parent
  end
end
