defmodule RealityAnchorWeb.API.SillyChallengeController do
  use RealityAnchorWeb, :controller

  alias RealityAnchor.Games

  action_fallback RealityAnchorWeb.FallbackController

  @doc """
  GET /api/v1/silly_challenges/:id - Show a specific challenge
  """
  def show(conn, %{"id" => id}) do
    case Games.get_silly_image_challenge(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Challenge not found"})
      challenge ->
        # Convert external image URLs to proxied URLs
        image_url = if String.starts_with?(challenge.image_url, "http://localhost:4000/") do
          challenge.image_url
        else
          encoded_url = URI.encode(challenge.image_url, &URI.char_unreserved?/1)
          "http://localhost:4000/proxy-image?url=#{encoded_url}"
        end

        json(conn, %{
          data: %{
            id: challenge.id,
            title: challenge.title,
            image_url: image_url,
            regions: challenge.regions,
            difficulty: challenge.difficulty,
            created_by_ai: challenge.created_by_ai,
            total_regions: length(challenge.regions),
            inserted_at: challenge.inserted_at,
            updated_at: challenge.updated_at
          }
        })
    end
  end

  @doc """
  POST /api/v1/silly_challenges/:id/submit - Submit taps for a challenge
  
  Expected payload:
  {
    "taps": [
      {"x": 0.32, "y": 0.42},
      {"x": 0.15, "y": 0.78}
    ]
  }
  """
  def submit(conn, %{"id" => id, "taps" => taps}) when is_list(taps) do
    case Games.get_silly_image_challenge(id) do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Challenge not found"})
      challenge ->
        result = Games.process_silly_challenge_submission(challenge, taps)
        json(conn, %{
          data: %{
            correct_taps: result.correct_taps,
            incorrect_taps: result.incorrect_taps,
            score: result.score,
            explanations: result.explanations,
            total_regions: result.total_regions,
            found_regions: result.found_regions,
            percentage: if(result.total_regions > 0, do: round(result.found_regions / result.total_regions * 100), else: 0)
          }
        })
    end
  end

  def submit(conn, %{"id" => _id}) do
    conn
    |> put_status(:bad_request)
    |> json(%{error: "Missing or invalid 'taps' parameter"})
  end

  @doc """
  GET /api/v1/silly_challenges/random - Get a random challenge
  """
  def random(conn, _params) do
    case Games.get_random_silly_image_challenge() do
      nil ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "No challenges available"})
      challenge ->
        # Convert external image URLs to proxied URLs
        image_url = if String.starts_with?(challenge.image_url, "http://localhost:4000/") do
          challenge.image_url
        else
          encoded_url = URI.encode(challenge.image_url, &URI.char_unreserved?/1)
          "http://localhost:4000/proxy-image?url=#{encoded_url}"
        end

        json(conn, %{
          data: %{
            id: challenge.id,
            title: challenge.title,
            image_url: image_url,
            regions: challenge.regions,
            difficulty: challenge.difficulty,
            created_by_ai: challenge.created_by_ai,
            total_regions: length(challenge.regions),
            inserted_at: challenge.inserted_at,
            updated_at: challenge.updated_at
          }
        })
    end
  end
end