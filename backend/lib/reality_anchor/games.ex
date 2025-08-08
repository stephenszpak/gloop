defmodule RealityAnchor.Games do
  @moduledoc """
  The Games context for managing game challenges and interactions.
  """

  import Ecto.Query, warn: false
  alias RealityAnchor.Repo
  alias RealityAnchor.Games.SillyImageChallenge

  @doc """
  Returns the list of silly image challenges.

  ## Examples

      iex> list_silly_image_challenges()
      [%SillyImageChallenge{}, ...]

  """
  def list_silly_image_challenges do
    Repo.all(SillyImageChallenge)
  end

  @doc """
  Returns the list of silly image challenges filtered by difficulty.

  ## Examples

      iex> list_silly_image_challenges_by_difficulty("easy")
      [%SillyImageChallenge{}, ...]

  """
  def list_silly_image_challenges_by_difficulty(difficulty) do
    SillyImageChallenge
    |> where([c], c.difficulty == ^difficulty)
    |> Repo.all()
  end

  @doc """
  Gets a single silly_image_challenge.

  Raises `Ecto.NoResultsError` if the Silly image challenge does not exist.

  ## Examples

      iex> get_silly_image_challenge!(123)
      %SillyImageChallenge{}

      iex> get_silly_image_challenge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_silly_image_challenge!(id), do: Repo.get!(SillyImageChallenge, id)

  @doc """
  Gets a single silly_image_challenge.

  Returns `nil` if the Silly image challenge does not exist.

  ## Examples

      iex> get_silly_image_challenge(123)
      %SillyImageChallenge{}

      iex> get_silly_image_challenge(456)
      nil

  """
  def get_silly_image_challenge(id), do: Repo.get(SillyImageChallenge, id)

  @doc """
  Creates a silly_image_challenge.

  ## Examples

      iex> create_silly_image_challenge(%{field: value})
      {:ok, %SillyImageChallenge{}}

      iex> create_silly_image_challenge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_silly_image_challenge(attrs \\ %{}) do
    %SillyImageChallenge{}
    |> SillyImageChallenge.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a silly_image_challenge.

  ## Examples

      iex> update_silly_image_challenge(silly_image_challenge, %{field: new_value})
      {:ok, %SillyImageChallenge{}}

      iex> update_silly_image_challenge(silly_image_challenge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_silly_image_challenge(%SillyImageChallenge{} = silly_image_challenge, attrs) do
    silly_image_challenge
    |> SillyImageChallenge.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a silly_image_challenge.

  ## Examples

      iex> delete_silly_image_challenge(silly_image_challenge)
      {:ok, %SillyImageChallenge{}}

      iex> delete_silly_image_challenge(silly_image_challenge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_silly_image_challenge(%SillyImageChallenge{} = silly_image_challenge) do
    Repo.delete(silly_image_challenge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking silly_image_challenge changes.

  ## Examples

      iex> change_silly_image_challenge(silly_image_challenge)
      %Ecto.Changeset{data: %SillyImageChallenge{}}

  """
  def change_silly_image_challenge(%SillyImageChallenge{} = silly_image_challenge, attrs \\ %{}) do
    SillyImageChallenge.changeset(silly_image_challenge, attrs)
  end

  @doc """
  Process a submission for a silly image challenge.
  
  Takes a list of tap coordinates and returns which taps were correct
  with their explanations.

  ## Examples

      iex> process_silly_challenge_submission(challenge, [%{x: 0.3, y: 0.4}])
      %{
        correct_taps: [%{x: 0.3, y: 0.4, region: %{...}}],
        incorrect_taps: [],
        score: 100,
        explanations: [%{label: "dog in sunglasses", explanation: "..."}]
      }
  """
  def process_silly_challenge_submission(%SillyImageChallenge{} = challenge, taps) when is_list(taps) do
    {correct_taps, incorrect_taps} = 
      taps
      |> Enum.map(fn tap ->
        case SillyImageChallenge.check_tap(challenge, tap["x"], tap["y"]) do
          nil -> {:incorrect, tap}
          region -> {:correct, Map.put(tap, "region", region)}
        end
      end)
      |> Enum.split_with(fn {result, _} -> result == :correct end)

    correct_tap_data = Enum.map(correct_taps, fn {_, tap} -> tap end)
    incorrect_tap_data = Enum.map(incorrect_taps, fn {_, tap} -> tap end)
    
    explanations = 
      correct_tap_data
      |> Enum.map(fn tap -> tap["region"] end)
      |> Enum.uniq_by(fn region -> region["label"] end)

    score = SillyImageChallenge.calculate_score(challenge, correct_tap_data)

    %{
      correct_taps: correct_tap_data,
      incorrect_taps: incorrect_tap_data,
      score: score,
      explanations: explanations,
      total_regions: length(challenge.regions),
      found_regions: length(explanations)
    }
  end

  @doc """
  Get a random silly image challenge by difficulty.
  """
  def get_random_silly_image_challenge(difficulty \\ "easy") do
    SillyImageChallenge
    |> where([c], c.difficulty == ^difficulty)
    |> order_by(fragment("RANDOM()"))
    |> limit(1)
    |> Repo.one()
  end
end