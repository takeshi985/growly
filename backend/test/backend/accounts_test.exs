defmodule Backend.AccountsTest do
  use Backend.DataCase

  alias Backend.Accounts

  describe "parents" do
    alias Backend.Accounts.Parent

    import Backend.AccountsFixtures

    @invalid_attrs %{email: nil}

    test "list_parents/0 returns all parents" do
      parent = parent_fixture()
      assert Accounts.list_parents() == [parent]
    end

    test "get_parent!/1 returns the parent with given id" do
      parent = parent_fixture()
      assert Accounts.get_parent!(parent.id) == parent
    end

    test "create_parent/1 with valid data creates a parent" do
      valid_attrs = %{email: "some email"}

      assert {:ok, %Parent{} = parent} = Accounts.create_parent(valid_attrs)
      assert parent.email == "some email"
    end

    test "create_parent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_parent(@invalid_attrs)
    end

    test "update_parent/2 with valid data updates the parent" do
      parent = parent_fixture()
      update_attrs = %{email: "some updated email"}

      assert {:ok, %Parent{} = parent} = Accounts.update_parent(parent, update_attrs)
      assert parent.email == "some updated email"
    end

    test "update_parent/2 with invalid data returns error changeset" do
      parent = parent_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_parent(parent, @invalid_attrs)
      assert parent == Accounts.get_parent!(parent.id)
    end

    test "delete_parent/1 deletes the parent" do
      parent = parent_fixture()
      assert {:ok, %Parent{}} = Accounts.delete_parent(parent)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_parent!(parent.id) end
    end

    test "change_parent/1 returns a parent changeset" do
      parent = parent_fixture()
      assert %Ecto.Changeset{} = Accounts.change_parent(parent)
    end
  end
end
