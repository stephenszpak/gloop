defmodule Mix.Tasks.RealityAnchor.Gen.Missions do
  @moduledoc """
  Generate sample missions for Reality Anchor app.
  
  ## Examples

      mix reality_anchor.gen.missions --count 10
      mix reality_anchor.gen.missions --type real_or_fake_image --difficulty 2
      
  ## Options

    * `--count` - Number of missions to generate (default: 5)
    * `--type` - Mission type (default: random)
    * `--difficulty` - Difficulty level 1-5 (default: random)
    * `--clear` - Clear existing missions first
  """
  
  use Mix.Task
  alias RealityAnchor.{Repo, Missions}
  alias RealityAnchor.Missions.Mission

  @shortdoc "Generate sample missions for testing"

  def run(args) do
    Mix.Task.run("app.start")
    
    {opts, _} = OptionParser.parse!(args, 
      strict: [count: :integer, type: :string, difficulty: :integer, clear: :boolean],
      aliases: [c: :count, t: :type, d: :difficulty]
    )
    
    count = Keyword.get(opts, :count, 5)
    mission_type = Keyword.get(opts, :type)
    difficulty = Keyword.get(opts, :difficulty)
    clear? = Keyword.get(opts, :clear, false)
    
    if clear? do
      IO.puts("🗑️  Clearing existing missions...")
      Repo.delete_all(Mission)
    end
    
    IO.puts("🎯 Generating #{count} missions...")
    
    for i <- 1..count do
      mission_data = generate_mission_data(i, mission_type, difficulty)
      
      case Missions.create_mission(mission_data) do
        {:ok, mission} ->
          IO.puts("✅ Created: #{mission.title} (#{mission.type}, level #{mission.difficulty_level})")
          
        {:error, changeset} ->
          IO.puts("❌ Failed to create mission #{i}: #{inspect(changeset.errors)}")
      end
    end
    
    IO.puts("🎉 Mission generation complete!")
  end

  defp generate_mission_data(index, type_override, difficulty_override) do
    types = ["real_or_fake_image", "real_or_fake_story", "real_or_fake_video", "real_or_fake_news"]
    type = type_override || Enum.random(types)
    difficulty = difficulty_override || Enum.random(1..3)
    
    base_data = %{
      title: generate_title(type, index),
      type: type,
      difficulty_level: difficulty,
      question_text: generate_question(type, difficulty),
      correct_answer: Enum.random([true, false]),
      explanation: generate_explanation(type),
      is_active: true,
      tags: generate_tags(type, difficulty)
    }
    
    # Add type-specific fields
    case type do
      "real_or_fake_image" ->
        Map.put(base_data, :image_url, "https://picsum.photos/400/300?random=#{index + 100}")
        
      "real_or_fake_video" ->
        Map.put(base_data, :content_url, "https://example.com/video/#{index}")
        
      "real_or_fake_story" ->
        Map.put(base_data, :content_url, "https://example.com/story/#{index}")
        
      "real_or_fake_news" ->
        base_data
        |> Map.put(:image_url, "https://picsum.photos/400/300?random=#{index + 200}")
        |> Map.put(:content_url, "https://example.com/news/#{index}")
    end
  end

  defp generate_title(type, index) do
    titles = case type do
      "real_or_fake_image" -> [
        "Spot the AI Image",
        "Real Photo or Digital Art?",
        "Nature or CGI?",
        "Authentic Image Check",
        "Photo Verification Challenge"
      ]
      "real_or_fake_story" -> [
        "Fact or Fiction?",
        "True Story Verification", 
        "News or Nonsense?",
        "Real Event Check",
        "Story Truth Test"
      ]
      "real_or_fake_video" -> [
        "Deepfake Detection",
        "Real or Fake Video?",
        "Video Authenticity Check",
        "CGI or Reality?",
        "Video Verification"
      ]
      "real_or_fake_news" -> [
        "News Fact Check",
        "Headline Reality Check",
        "True News or Fake?",
        "News Source Verification",
        "Media Literacy Test"
      ]
    end
    
    "#{Enum.random(titles)} ##{index}"
  end

  defp generate_question(type, difficulty) do
    questions = case {type, difficulty} do
      {"real_or_fake_image", 1} -> [
        "Is this a real photo or made by a computer? 🤔",
        "Does this picture show something real? 📷",
        "Is this image real or fake? 🖼️"
      ]
      {"real_or_fake_image", _} -> [
        "Can you tell if this image is authentic or AI-generated? 🔍",
        "Is this a genuine photograph or digitally created? 🎨",
        "Does this image show reality or is it artificially created? 🤖"
      ]
      {"real_or_fake_story", 1} -> [
        "Is this story true or made up? 📖",
        "Did this really happen? 🤷",
        "Is this a real story? 📚"
      ]
      {"real_or_fake_story", _} -> [
        "Can you verify if this story is factual? 📊",
        "Is this account based on real events? 🔎", 
        "Does this story contain accurate information? ✅"
      ]
      {"real_or_fake_video", _} -> [
        "Is this video showing real events? 🎥",
        "Can you detect if this video has been manipulated? 🎬",
        "Is this footage authentic? 📹"
      ]
      {"real_or_fake_news", _} -> [
        "Is this a reliable news report? 📰",
        "Can you verify this news story? 🔍",
        "Is this legitimate journalism? 📺"
      ]
    end
    
    Enum.random(questions)
  end

  defp generate_explanation(type) do
    explanations = case type do
      "real_or_fake_image" -> [
        "✅ This is authentic! Look for natural lighting and consistent details.",
        "❌ This was AI-generated! Notice the unnatural patterns and perfect symmetry.",
        "✅ Real photo! Professional photographers use good lighting and composition.",
        "❌ Computer-created! The textures and shadows don't match reality."
      ]
      "real_or_fake_story" -> [
        "✅ This story is factual! It's been verified by multiple reliable sources.",
        "❌ This is false information! Always check multiple sources before believing.",
        "✅ True story! Historical records and witnesses confirm these events.",
        "❌ Made-up story! No credible sources support these claims."
      ]
      "real_or_fake_video" -> [
        "✅ Authentic video! The movements and lighting appear natural.",
        "❌ Manipulated footage! Look for inconsistent lighting and unnatural movements.",
        "✅ Real recording! Everything matches what we'd expect in reality.",
        "❌ Deepfake or CGI! The facial expressions and movements are too perfect."
      ]
      "real_or_fake_news" -> [
        "✅ Legitimate news! This comes from a credible, fact-checked source.",
        "❌ Fake news! This story lacks verification and credible sources.",
        "✅ Verified reporting! Multiple trustworthy outlets confirm this story.",
        "❌ Misinformation! Be careful of sensational headlines without evidence."
      ]
    end
    
    Enum.random(explanations)
  end

  defp generate_tags(type, difficulty) do
    base_tags = case difficulty do
      1 -> ["beginner", "easy"]
      2 -> ["intermediate", "medium"] 
      3 -> ["advanced", "hard"]
      _ -> ["expert", "very-hard"]
    end
    
    type_tags = case type do
      "real_or_fake_image" -> ["visual", "photo", "ai"]
      "real_or_fake_story" -> ["text", "narrative", "facts"]
      "real_or_fake_video" -> ["video", "motion", "deepfake"] 
      "real_or_fake_news" -> ["news", "media", "journalism"]
    end
    
    base_tags ++ type_tags ++ [Enum.random(["sample", "generated", "test"])]
  end
end