defmodule RealityAnchorWeb.ImageController do
  use RealityAnchorWeb, :controller

  def images(conn, %{"path" => path}) do
    file_path = Path.join([Application.app_dir(:reality_anchor), "priv", "static", "images"] ++ path)
    
    if File.exists?(file_path) do
      conn
      |> put_resp_content_type("image/png")
      |> put_resp_header("cache-control", "public, max-age=31536000")
      |> send_file(200, file_path)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Image not found"})
    end
  end

  @doc """
  Proxy external image URLs to work around CORS/network issues
  GET /proxy-image?url=<encoded_url>
  """
  def proxy(conn, %{"url" => external_url}) do
    case Finch.build(:get, external_url) |> Finch.request(RealityAnchor.Finch) do
      {:ok, %{status: 200, body: image_data, headers: headers}} ->
        content_type = 
          headers
          |> Enum.find(fn {key, _} -> String.downcase(key) == "content-type" end)
          |> case do
            {_, type} -> type
            nil -> "image/png"
          end

        conn
        |> put_resp_content_type(content_type)
        |> put_resp_header("cache-control", "public, max-age=3600")
        |> put_resp_header("access-control-allow-origin", "*")
        |> send_resp(200, image_data)
      
      {:ok, %{status: status}} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "Failed to fetch image", status: status})
      
      {:error, _reason} ->
        conn
        |> put_status(:bad_gateway)
        |> json(%{error: "Failed to fetch image"})
    end
  end
end