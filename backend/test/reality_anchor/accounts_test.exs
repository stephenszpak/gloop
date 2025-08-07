defmodule RealityAnchor.AccountsTest do
  use RealityAnchor.DataCase
  import RealityAnchor.Factory

  alias RealityAnchor.Accounts

  describe "users" do
    alias RealityAnchor.Accounts.User

    @valid_attrs %{email: "test@example.com", name: "Test User", password: "password123"}
    @invalid_attrs %{email: nil, name: nil, password: nil}

    test "get_user_by_email/1 returns user with given email" do
      user = insert(:user)
      assert Accounts.get_user_by_email(user.email) == user
    end

    test "get_user_by_email/1 returns nil for non-existent email" do
      assert Accounts.get_user_by_email("nonexistent@example.com") == nil
    end

    test "get_user_by_email_and_password/2 authenticates user with correct credentials" do
      user = insert(:user, password_hash: Bcrypt.hash_pwd_salt("password123"))
      
      assert Accounts.get_user_by_email_and_password(user.email, "password123") == user
    end

    test "get_user_by_email_and_password/2 returns nil with incorrect password" do
      user = insert(:user, password_hash: Bcrypt.hash_pwd_salt("password123"))
      
      assert Accounts.get_user_by_email_and_password(user.email, "wrongpassword") == nil
    end

    test "register_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.register_user(@valid_attrs)
      assert user.email == "test@example.com"
      assert user.name == "Test User"
      assert user.password_hash
    end

    test "register_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(@invalid_attrs)
    end

    test "register_user/1 with duplicate email returns error changeset" do
      user = insert(:user)
      attrs = %{@valid_attrs | email: user.email}
      
      assert {:error, %Ecto.Changeset{}} = Accounts.register_user(attrs)
    end
  end

  describe "child_profiles" do
    alias RealityAnchor.Accounts.ChildProfile

    test "list_child_profiles_for_user/1 returns all child profiles for user" do
      user = insert(:user)
      child1 = insert(:child_profile, user: user, name: "Alice")
      child2 = insert(:child_profile, user: user, name: "Bob")
      _other_child = insert(:child_profile, name: "Charlie")

      children = Accounts.list_child_profiles_for_user(user.id)
      
      assert length(children) == 2
      assert Enum.map(children, & &1.name) == ["Alice", "Bob"]
    end

    test "get_child_profile_for_user!/2 returns child profile when it belongs to user" do
      user = insert(:user)
      child = insert(:child_profile, user: user)

      result = Accounts.get_child_profile_for_user!(user.id, child.id)
      assert result.id == child.id
    end

    test "get_child_profile_for_user!/2 raises when child doesn't belong to user" do
      user1 = insert(:user)
      user2 = insert(:user)
      child = insert(:child_profile, user: user2)

      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_child_profile_for_user!(user1.id, child.id)
      end
    end

    test "create_child_profile/1 with valid data creates a child profile" do
      user = insert(:user)
      valid_attrs = %{name: "Emma", avatar_emoji: "🦄", birth_year: 2018, user_id: user.id}

      assert {:ok, %ChildProfile{} = child} = Accounts.create_child_profile(valid_attrs)
      assert child.name == "Emma"
      assert child.avatar_emoji == "🦄"
      assert child.birth_year == 2018
    end

    test "create_child_profile/1 prevents duplicate names for same user" do
      user = insert(:user)
      insert(:child_profile, user: user, name: "Emma")

      duplicate_attrs = %{name: "Emma", avatar_emoji: "🚀", user_id: user.id}
      assert {:error, %Ecto.Changeset{}} = Accounts.create_child_profile(duplicate_attrs)
    end

    test "create_child_profile/1 allows same name for different users" do
      user1 = insert(:user)
      user2 = insert(:user)
      insert(:child_profile, user: user1, name: "Emma")

      attrs = %{name: "Emma", avatar_emoji: "🌟", user_id: user2.id}
      assert {:ok, %ChildProfile{}} = Accounts.create_child_profile(attrs)
    end

    test "ChildProfile.age/1 calculates correct age from birth year" do
      current_year = Date.utc_today().year
      child = build(:child_profile, birth_year: current_year - 6)
      
      assert ChildProfile.age(child) == 6
    end

    test "ChildProfile.age/1 returns nil when birth_year is nil" do
      child = build(:child_profile, birth_year: nil)
      
      assert ChildProfile.age(child) == nil
    end
  end
end