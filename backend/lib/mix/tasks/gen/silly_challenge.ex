defmodule Mix.Tasks.Gen.SillyChallenge do
  @moduledoc """
  Generates silly image challenges for the "Spot the Silly Thing" game using OpenAI APIs.

  ## Usage

      mix gen.silly_challenge "A silly kitchen scene with a toaster wearing sunglasses and a fork dancing"

  This task will:
  1. Generate an image using DALL-E based on the provided prompt
  2. Use GPT-4o Vision to detect silly objects and their bounding boxes
  3. Create a challenge record in the database with proper difficulty classification
  """

  use Mix.Task
  
  alias RealityAnchor.Games

  @shortdoc "Generates a silly image challenge using OpenAI APIs"

  @openai_api_url "https://api.openai.com/v1"
  @image_generation_endpoint "#{@openai_api_url}/images/generations"
  @chat_completions_endpoint "#{@openai_api_url}/chat/completions"

  def run(args) do
    Mix.Task.run("app.start")
    
    case args do
      [prompt] when is_binary(prompt) ->
        generate_challenge(prompt)
      [] ->
        Mix.shell().error("Error: Please provide a prompt for the silly challenge.")
        Mix.shell().info("Usage: mix gen.silly_challenge \"Your prompt here\"")
      _ ->
        Mix.shell().error("Error: Please provide exactly one prompt argument.")
    end
  end

  defp generate_challenge(prompt) do
    Mix.shell().info("🎨 Generating silly challenge from prompt: \"#{prompt}\"")
    
    with {:ok, api_key} <- get_openai_api_key(),
         {:ok, image_url} <- generate_image(prompt, api_key),
         {:ok, challenge_data} <- analyze_image_for_silly_things(image_url, prompt, api_key),
         {:ok, _challenge} <- save_challenge_to_db(challenge_data) do
      
      Mix.shell().info("✅ Successfully created silly challenge!")
      display_challenge_summary(challenge_data)
    else
      {:error, reason} ->
        Mix.shell().error("❌ Failed to generate challenge: #{reason}")
        System.halt(1)
    end
  end

  defp get_openai_api_key do
    case System.get_env("OPENAI_API_KEY") do
      nil ->
        # Try to load from .env file if environment variable is not set
        case load_env_file() do
          {:ok, key} -> {:ok, key}
          {:error, _} ->
            Mix.shell().error("Please set the OPENAI_API_KEY environment variable or add it to .env file")
            {:error, "Missing OPENAI_API_KEY"}
        end
      key when is_binary(key) ->
        {:ok, key}
    end
  end

  defp load_env_file do
    env_file = Path.join([File.cwd!(), ".env"])
    
    if File.exists?(env_file) do
      case File.read(env_file) do
        {:ok, content} ->
          content
          |> String.split("\n")
          |> Enum.find(&String.starts_with?(&1, "OPENAI_API_KEY="))
          |> case do
            "OPENAI_API_KEY=" <> key ->
              key = String.trim(key)
              System.put_env("OPENAI_API_KEY", key)
              {:ok, key}
            nil ->
              {:error, "OPENAI_API_KEY not found in .env file"}
          end
        {:error, reason} ->
          {:error, "Failed to read .env file: #{reason}"}
      end
    else
      {:error, ".env file not found"}
    end
  end

  defp generate_image(prompt, api_key) do
    Mix.shell().info("🖼️  Generating image with DALL-E...")
    
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    # Enhanced prompt for silly imagery
    enhanced_prompt = """
    Create a cartoon-style illustration of #{prompt}. 
    
    STYLE REQUIREMENTS:
    - Bright, vibrant cartoon style similar to children's picture books
    - Bold, clean outlines around all objects
    - Smooth, simple shading with flat colors
    - No photorealistic textures or details
    - Friendly, child-appropriate cartoon aesthetic
    - Think Disney/Pixar animation style
    
    COMPOSITION:
    - Make it whimsical with clearly silly, absurd elements that would be obvious to children
    - Ensure objects are well-separated with clear, distinct boundaries for easy identification
    - Use bright, contrasting colors to make silly objects stand out
    - Simple, uncluttered background so objects are easy to spot
    - Large, exaggerated silly elements that are unmistakably out of place
    
    SILLY ELEMENTS:
    - Make absurd situations very obvious (like animals in wrong places, objects with impossible features)
    - Use exaggerated expressions and poses
    - Add whimsical details that clearly don't belong in the scene
    """

    body = %{
      "model" => "dall-e-3",
      "prompt" => enhanced_prompt,
      "size" => "1024x1024",
      "quality" => "standard",
      "n" => 1
    }

    case Finch.build(:post, @image_generation_endpoint, headers, Jason.encode!(body))
         |> Finch.request(RealityAnchor.Finch) do
      {:ok, %{status: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"data" => [%{"url" => temp_image_url}]}} ->
            Mix.shell().info("✅ Image generated successfully!")
            # Download and store the image locally
            case download_and_store_image(temp_image_url) do
              {:ok, local_url} ->
                Mix.shell().info("📁 Image downloaded and stored locally")
                {:ok, local_url}
              {:error, _} ->
                # Fall back to temporary URL if download fails
                Mix.shell().info("⚠️  Using temporary URL (download failed)")
                {:ok, temp_image_url}
            end
          {:error, _} ->
            {:error, "Failed to parse image generation response"}
        end
      {:ok, %{status: status, body: body}} ->
        {:error, "Image generation failed with status #{status}: #{body}"}
      {:error, reason} ->
        {:error, "Network error during image generation: #{inspect(reason)}"}
    end
  end

  defp download_and_store_image(image_url) do
    # Create unique filename
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    filename = "silly_challenge_#{timestamp}.png"
    
    # Ensure priv/static/images directory exists
    images_dir = Path.join([File.cwd!(), "priv", "static", "images"])
    File.mkdir_p!(images_dir)
    
    file_path = Path.join(images_dir, filename)
    
    case Finch.build(:get, image_url) |> Finch.request(RealityAnchor.Finch) do
      {:ok, %{status: 200, body: image_data}} ->
        case File.write(file_path, image_data) do
          :ok ->
            # Return the public URL that Phoenix will serve
            local_url = "http://localhost:4000/images/#{filename}"
            {:ok, local_url}
          {:error, reason} ->
            {:error, "Failed to write image file: #{reason}"}
        end
      {:error, reason} ->
        {:error, "Failed to download image: #{inspect(reason)}"}
    end
  end

  defp analyze_image_for_silly_things(image_url, original_prompt, api_key) do
    Mix.shell().info("🔍 Analyzing image for silly objects with GPT-4o Vision...")
    
    headers = [
      {"Authorization", "Bearer #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    # Detailed system prompt for consistent silly object detection
    system_prompt = """
    You are an AI assistant helping to create a children's game called "Spot the Silly Thing". 
    Your job is to identify absurd, silly, or out-of-place objects in cartoon-style images.

    The images are bright, colorful cartoon illustrations designed for children. Look for:
    - Objects that are clearly out of place (penguin at the beach, fish on land, etc.)
    - Inanimate objects doing human activities (clocks reading books, spoons dancing, etc.)  
    - Animals or objects with impossible features (dogs with wings, flying furniture, etc.)
    - Absurd situations that would make children laugh

    Analyze the provided cartoon image and return ONLY a valid JSON object with this exact structure:
    {
      "title": "Brief descriptive title (3-5 words)",
      "regions": [
        {
          "x": 0.0,
          "y": 0.0,
          "width": 0.0,
          "height": 0.0,
          "label": "brief description of silly object",
          "explanation": "why this is silly or absurd"
        }
      ],
      "difficulty": "easy"
    }

    IMPORTANT RULES:
    - x, y, width, height must be normalized coordinates between 0.0 and 1.0
    - x,y represents the TOP-LEFT corner of the bounding box
    - Only identify truly silly/absurd things that stand out in the cartoon scene
    - Focus on obvious silly elements with bold outlines and bright colors
    - Aim for 2-4 silly regions maximum to keep it fun for kids
    - Keep labels concise (2-4 words) and child-friendly
    - Make explanations fun and clear for children aged 5-10
    - Set difficulty based on number of regions: 1-2 = "easy", 3-4 = "medium", 5+ = "hard"
    - Look for exaggerated, cartoon-style silly elements that are easy to spot
    
    Return ONLY the JSON, no additional text or formatting.
    """

    user_prompt = """
    Please analyze this image and identify silly/absurd objects with their bounding boxes. 
    The original generation prompt was: "#{original_prompt}"
    """

    body = %{
      "model" => "gpt-4o",
      "messages" => [
        %{
          "role" => "system", 
          "content" => system_prompt
        },
        %{
          "role" => "user",
          "content" => [
            %{"type" => "text", "text" => user_prompt},
            %{"type" => "image_url", "image_url" => %{"url" => image_url}}
          ]
        }
      ],
      "max_tokens" => 1000
    }

    case Finch.build(:post, @chat_completions_endpoint, headers, Jason.encode!(body))
         |> Finch.request(RealityAnchor.Finch) do
      {:ok, %{status: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"choices" => [%{"message" => %{"content" => content}}]}} ->
            parse_silly_analysis(content, image_url)
          {:error, _} ->
            {:error, "Failed to parse vision analysis response"}
        end
      {:ok, %{status: status, body: body}} ->
        {:error, "Vision analysis failed with status #{status}: #{body}"}
      {:error, reason} ->
        {:error, "Network error during vision analysis: #{inspect(reason)}"}
    end
  end

  defp parse_silly_analysis(content, image_url) do
    # Clean up the content in case GPT includes markdown formatting
    cleaned_content = content
                     |> String.replace("```json", "")
                     |> String.replace("```", "")
                     |> String.trim()

    case Jason.decode(cleaned_content) do
      {:ok, %{"title" => title, "regions" => regions, "difficulty" => difficulty}} ->
        # Validate and clean up the data
        validated_regions = validate_and_clean_regions(regions)
        
        challenge_data = %{
          "title" => title,
          "image_url" => image_url,
          "regions" => validated_regions,
          "difficulty" => difficulty,
          "created_by_ai" => true
        }
        
        Mix.shell().info("✅ Found #{length(validated_regions)} silly objects!")
        {:ok, challenge_data}
      
      {:ok, invalid_structure} ->
        Mix.shell().error("Invalid JSON structure from GPT-4o Vision")
        Mix.shell().error("Received: #{inspect(invalid_structure)}")
        {:error, "Invalid response structure from vision analysis"}
      
      {:error, json_error} ->
        Mix.shell().error("Failed to parse JSON from GPT-4o Vision:")
        Mix.shell().error("Content: #{content}")
        Mix.shell().error("Error: #{inspect(json_error)}")
        {:error, "Invalid JSON from vision analysis"}
    end
  end

  defp validate_and_clean_regions(regions) when is_list(regions) do
    regions
    |> Enum.filter(&valid_region?/1)
    |> Enum.map(&clean_region/1)
  end

  defp validate_and_clean_regions(_), do: []

  defp valid_region?(%{
    "x" => x, "y" => y, "width" => w, "height" => h,
    "label" => label, "explanation" => explanation
  }) when is_number(x) and is_number(y) and is_number(w) and is_number(h) and
          is_binary(label) and is_binary(explanation) do
    x >= 0.0 and x <= 1.0 and
    y >= 0.0 and y <= 1.0 and
    w > 0.0 and w <= 1.0 and
    h > 0.0 and h <= 1.0 and
    String.length(String.trim(label)) > 0 and
    String.length(String.trim(explanation)) > 0
  end
  
  defp valid_region?(_), do: false

  defp clean_region(region) do
    %{
      "x" => Float.round(region["x"], 3),
      "y" => Float.round(region["y"], 3),
      "width" => Float.round(region["width"], 3),
      "height" => Float.round(region["height"], 3),
      "label" => String.trim(region["label"]),
      "explanation" => String.trim(region["explanation"])
    }
  end

  defp save_challenge_to_db(challenge_data) do
    Mix.shell().info("💾 Saving challenge to database...")
    
    case Games.create_silly_image_challenge(challenge_data) do
      {:ok, challenge} ->
        Mix.shell().info("✅ Challenge saved with ID: #{challenge.id}")
        {:ok, challenge}
      {:error, changeset} ->
        errors = Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)
        Mix.shell().error("Database save failed:")
        Mix.shell().error(inspect(errors))
        {:error, "Database save failed: #{inspect(errors)}"}
    end
  end

  defp display_challenge_summary(challenge_data) do
    Mix.shell().info("\n🎉 Challenge Summary:")
    Mix.shell().info("📝 Title: #{challenge_data["title"]}")
    Mix.shell().info("🖼️  Image: #{challenge_data["image_url"]}")
    Mix.shell().info("⭐ Difficulty: #{challenge_data["difficulty"]}")
    Mix.shell().info("🎯 Silly Objects Found:")
    
    challenge_data["regions"]
    |> Enum.with_index(1)
    |> Enum.each(fn {region, index} ->
      Mix.shell().info("  #{index}. #{region["label"]} - #{region["explanation"]}")
    end)
    
    Mix.shell().info("\n🚀 Ready to play! Use challenge ID in your Flutter app.")
  end
end