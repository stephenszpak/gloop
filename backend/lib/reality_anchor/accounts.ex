defmodule RealityAnchor.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias RealityAnchor.Repo
  alias RealityAnchor.Accounts.{User, ChildProfile}

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  @doc """
  Gets a user by email and password.

  ## Examples

      iex> get_user_by_email_and_password("foo@example.com", "correct_password")
      %User{}

      iex> get_user_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_user_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    user = get_user_by_email(email)
    if User.valid_password?(user, password), do: user
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  ## User registration

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user_registration(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_registration(%User{} = user, attrs \\ %{}) do
    User.registration_changeset(user, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user profile.

  ## Examples

      iex> change_user_profile(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_profile(%User{} = user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  @doc """
  Updates the user profile.

  ## Examples

      iex> update_user_profile(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_profile(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_profile(%User{} = user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  ## Child Profiles

  @doc """
  Returns the list of child_profiles for a user.

  ## Examples

      iex> list_child_profiles_for_user(user_id)
      [%ChildProfile{}, ...]

  """
  def list_child_profiles_for_user(user_id) do
    from(cp in ChildProfile, 
         where: cp.user_id == ^user_id,
         order_by: [asc: cp.name])
    |> Repo.all()
  end

  @doc """
  Gets a single child_profile.

  Raises `Ecto.NoResultsError` if the Child profile does not exist.

  ## Examples

      iex> get_child_profile!(123)
      %ChildProfile{}

      iex> get_child_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_child_profile!(id), do: Repo.get!(ChildProfile, id)

  @doc """
  Gets a child profile that belongs to a specific user.
  """
  def get_child_profile_for_user!(user_id, child_id) do
    from(cp in ChildProfile, 
         where: cp.id == ^child_id and cp.user_id == ^user_id)
    |> Repo.one!()
  end

  @doc """
  Creates a child_profile.

  ## Examples

      iex> create_child_profile(%{field: value})
      {:ok, %ChildProfile{}}

      iex> create_child_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_child_profile(attrs \\ %{}) do
    %ChildProfile{}
    |> ChildProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a child_profile.

  ## Examples

      iex> update_child_profile(child_profile, %{field: new_value})
      {:ok, %ChildProfile{}}

      iex> update_child_profile(child_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_child_profile(%ChildProfile{} = child_profile, attrs) do
    child_profile
    |> ChildProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a child_profile.

  ## Examples

      iex> delete_child_profile(child_profile)
      {:ok, %ChildProfile{}}

      iex> delete_child_profile(child_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_child_profile(%ChildProfile{} = child_profile) do
    Repo.delete(child_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking child_profile changes.

  ## Examples

      iex> change_child_profile(child_profile)
      %Ecto.Changeset{data: %ChildProfile{}}

  """
  def change_child_profile(%ChildProfile{} = child_profile, attrs \\ %{}) do
    ChildProfile.changeset(child_profile, attrs)
  end
end