defmodule RealityAnchorWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use RealityAnchorWeb, :controller

  # This clause handles errors returned by Ecto's insert/update/delete.
  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RealityAnchorWeb.ErrorJSON)
    |> render(:changeset, changeset: changeset)
  end

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: RealityAnchorWeb.ErrorJSON)
    |> render(:"404")
  end
  
  # Handle other common errors
  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:unauthorized)
    |> put_view(json: RealityAnchorWeb.ErrorJSON)
    |> render(:error, %{message: "Unauthorized"})
  end

  def call(conn, {:error, :forbidden}) do
    conn
    |> put_status(:forbidden)
    |> put_view(json: RealityAnchorWeb.ErrorJSON)
    |> render(:error, %{message: "Forbidden"})
  end
end