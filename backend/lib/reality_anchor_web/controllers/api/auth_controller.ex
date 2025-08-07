defmodule RealityAnchorWeb.API.AuthController do
  use RealityAnchorWeb, :controller
  
  alias RealityAnchor.{Accounts, Guardian}

  action_fallback RealityAnchorWeb.FallbackController

  @doc """
  POST /api/v1/auth/register
  Register a new parent account
  """
  def register(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        
        conn
        |> put_status(:created)
        |> render(:user_with_token, %{user: user, token: token})

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, %{changeset: changeset})
    end
  end

  @doc """
  POST /api/v1/auth/login  
  Login parent with email/password
  """
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.get_user_by_email_and_password(email, password) do
      %Accounts.User{} = user ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        
        render(conn, :user_with_token, %{user: user, token: token})

      nil ->
        conn
        |> put_status(:unauthorized)
        |> render(:error, %{message: "Invalid email or password"})
    end
  end

  @doc """
  POST /api/v1/auth/logout
  Logout (revoke token)
  """
  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)
    
    render(conn, :message, %{message: "Logged out successfully"})
  end

  @doc """
  GET /api/v1/auth/me
  Get current user profile with children
  """
  def me(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    children = Accounts.list_child_profiles_for_user(user.id)
    
    render(conn, :user_with_children, %{user: user, children: children})
  end
end