defmodule RealityAnchorWeb.API.AuthJSON do
  alias RealityAnchor.Accounts.User

  @doc """
  Renders user with JWT token for login/register
  """
  def user_with_token(%{user: user, token: token}) do
    %{
      data: %{
        user: user_data(user),
        token: token
      }
    }
  end

  @doc """
  Renders user with their children
  """
  def user_with_children(%{user: user, children: children}) do
    %{
      data: %{
        user: user_data(user),
        children: for(child <- children, do: child_data(child))
      }
    }
  end

  @doc """
  Renders a simple message
  """
  def message(%{message: message}) do
    %{data: %{message: message}}
  end

  @doc """
  Renders error message
  """
  def error(%{message: message}) do
    %{error: %{message: message}}
  end

  @doc """
  Renders validation errors
  """
  def errors(%{changeset: changeset}) do
    %{error: %{message: "Validation failed", details: translate_errors(changeset)}}
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      confirmed_at: user.confirmed_at,
      inserted_at: user.inserted_at
    }
  end

  defp child_data(child) do
    %{
      id: child.id,
      name: child.name,
      avatar_emoji: child.avatar_emoji,
      birth_year: child.birth_year,
      age: RealityAnchor.Accounts.ChildProfile.age(child),
      inserted_at: child.inserted_at
    }
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end