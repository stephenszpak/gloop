defmodule RealityAnchorWeb.API.AuthControllerTest do
  use RealityAnchorWeb.ConnCase
  import RealityAnchor.Factory

  alias RealityAnchor.Guardian

  describe "POST /api/v1/auth/register" do
    @valid_attrs %{
      "user" => %{
        "name" => "Test User",
        "email" => "test@example.com", 
        "password" => "password123"
      }
    }

    test "creates user and returns JWT token with valid data", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/register", @valid_attrs)

      assert %{
        "data" => %{
          "user" => user_data,
          "token" => token
        }
      } = json_response(conn, 201)

      assert user_data["email"] == "test@example.com"
      assert user_data["name"] == "Test User"
      assert is_binary(token)
      
      # Verify token is valid
      assert {:ok, _claims} = Guardian.decode_and_verify(token)
    end

    test "returns error with invalid data", %{conn: conn} do
      invalid_attrs = %{"user" => %{"email" => "invalid", "password" => "123"}}
      conn = post(conn, ~p"/api/v1/auth/register", invalid_attrs)

      assert %{"error" => %{"message" => "Validation failed"}} = json_response(conn, 422)
    end

    test "returns error with duplicate email", %{conn: conn} do
      insert(:user, email: "test@example.com")
      
      conn = post(conn, ~p"/api/v1/auth/register", @valid_attrs)

      assert %{"error" => %{"message" => "Validation failed"}} = json_response(conn, 422)
    end
  end

  describe "POST /api/v1/auth/login" do
    test "returns JWT token with valid credentials", %{conn: conn} do
      user = insert(:user, 
        email: "test@example.com",
        password_hash: Bcrypt.hash_pwd_salt("password123")
      )

      login_attrs = %{"email" => "test@example.com", "password" => "password123"}
      conn = post(conn, ~p"/api/v1/auth/login", login_attrs)

      assert %{
        "data" => %{
          "user" => user_data,
          "token" => token
        }
      } = json_response(conn, 200)

      assert user_data["id"] == user.id
      assert user_data["email"] == "test@example.com"
      assert is_binary(token)
    end

    test "returns error with invalid credentials", %{conn: conn} do
      insert(:user, email: "test@example.com")

      login_attrs = %{"email" => "test@example.com", "password" => "wrongpassword"}
      conn = post(conn, ~p"/api/v1/auth/login", login_attrs)

      assert %{"error" => %{"message" => "Invalid email or password"}} = json_response(conn, 401)
    end

    test "returns error with non-existent email", %{conn: conn} do
      login_attrs = %{"email" => "nonexistent@example.com", "password" => "password123"}
      conn = post(conn, ~p"/api/v1/auth/login", login_attrs)

      assert %{"error" => %{"message" => "Invalid email or password"}} = json_response(conn, 401)
    end
  end

  describe "GET /api/v1/auth/me" do
    setup %{conn: conn} do
      user = insert(:user) |> with_children(2)
      {:ok, token, _claims} = Guardian.encode_and_sign(user)
      
      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn, user: user}
    end

    test "returns current user with children", %{conn: conn, user: user} do
      conn = get(conn, ~p"/api/v1/auth/me")

      assert %{
        "data" => %{
          "user" => user_data,
          "children" => children_data
        }
      } = json_response(conn, 200)

      assert user_data["id"] == user.id
      assert user_data["email"] == user.email
      assert length(children_data) == 2
    end

    test "returns 401 without authentication", %{conn: conn} do
      conn = 
        conn
        |> delete_req_header("authorization")
        |> get(~p"/api/v1/auth/me")

      assert %{"error" => %{"message" => "Authentication required"}} = json_response(conn, 401)
    end

    test "returns 401 with invalid token", %{conn: conn} do
      conn = 
        conn
        |> put_req_header("authorization", "Bearer invalid.token.here")
        |> get(~p"/api/v1/auth/me")

      assert %{"error" => %{"message" => "Invalid token"}} = json_response(conn, 401)
    end
  end

  describe "POST /api/v1/auth/logout" do
    setup %{conn: conn} do
      user = insert(:user)
      {:ok, token, _claims} = Guardian.encode_and_sign(user)
      
      conn = put_req_header(conn, "authorization", "Bearer #{token}")
      {:ok, conn: conn, token: token}
    end

    test "successfully logs out user", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/auth/logout")

      assert %{"data" => %{"message" => "Logged out successfully"}} = json_response(conn, 200)
    end

    test "returns 401 without authentication" do
      conn = build_conn()
      conn = post(conn, ~p"/api/v1/auth/logout")

      assert %{"error" => %{"message" => "Authentication required"}} = json_response(conn, 401)
    end
  end
end