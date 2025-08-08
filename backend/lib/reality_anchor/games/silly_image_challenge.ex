defmodule RealityAnchor.Games.SillyImageChallenge do
  use Ecto.Schema
  import Ecto.Changeset

  schema "silly_image_challenges" do
    field :title, :string
    field :image_url, :string
    field :regions, {:array, :map}, default: []
    field :difficulty, :string, default: "easy"
    field :created_by_ai, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @difficulties ~w(easy medium hard)

  @doc """
  Changeset for creating/updating silly image challenges.

  ## Region Format
  Each region should have:
  - `x`, `y`: Position as floats (0.0-1.0, normalized coordinates)
  - `width`, `height`: Size as floats (0.0-1.0, normalized coordinates)
  - `label`: String describing what's silly
  - `explanation`: String explaining why it's silly

  ## Example regions:
      [
        %{
          "x" => 0.32,
          "y" => 0.42,
          "width" => 0.1,
          "height" => 0.12,
          "label" => "dog wearing sunglasses",
          "explanation" => "Dogs don't usually wear sunglasses!"
        }
      ]
  """
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:title, :image_url, :regions, :difficulty, :created_by_ai])
    |> validate_required([:title, :image_url, :regions])
    |> validate_inclusion(:difficulty, @difficulties)
    |> validate_regions()
  end

  defp validate_regions(changeset) do
    case get_change(changeset, :regions) do
      nil -> changeset
      regions when is_list(regions) ->
        if Enum.all?(regions, &valid_region?/1) do
          changeset
        else
          add_error(changeset, :regions, "contains invalid region format")
        end
      _ ->
        add_error(changeset, :regions, "must be a list of region maps")
    end
  end

  defp valid_region?(%{} = region) do
    required_keys = ["x", "y", "width", "height", "label", "explanation"]
    
    Enum.all?(required_keys, fn key -> Map.has_key?(region, key) end) &&
    is_number(region["x"]) && region["x"] >= 0.0 && region["x"] <= 1.0 &&
    is_number(region["y"]) && region["y"] >= 0.0 && region["y"] <= 1.0 &&
    is_number(region["width"]) && region["width"] > 0.0 && region["width"] <= 1.0 &&
    is_number(region["height"]) && region["height"] > 0.0 && region["height"] <= 1.0 &&
    is_binary(region["label"]) && String.length(region["label"]) > 0 &&
    is_binary(region["explanation"]) && String.length(region["explanation"]) > 0
  end

  defp valid_region?(_), do: false

  @doc """
  Check if a tap at coordinates (x, y) hits any silly region.
  Returns the region if hit, nil otherwise.
  """
  def check_tap(%__MODULE__{regions: regions}, tap_x, tap_y) when is_number(tap_x) and is_number(tap_y) do
    Enum.find(regions, fn region ->
      x = region["x"]
      y = region["y"]
      width = region["width"]
      height = region["height"]
      
      tap_x >= x && tap_x <= (x + width) &&
      tap_y >= y && tap_y <= (y + height)
    end)
  end

  @doc """
  Calculate score based on correct taps vs total regions.
  """
  def calculate_score(%__MODULE__{regions: regions}, correct_taps) do
    total_regions = length(regions)
    correct_count = length(correct_taps)
    
    if total_regions > 0 do
      round((correct_count / total_regions) * 100)
    else
      0
    end
  end
end