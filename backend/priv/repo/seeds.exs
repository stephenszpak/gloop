# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RealityAnchor.Repo.insert!(%RealityAnchor.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias RealityAnchor.{Repo, Accounts, Missions}
alias RealityAnchor.Missions.Mission

# Clear existing data in development
if Mix.env() == :dev do
  Repo.delete_all(Missions.Submission)
  Repo.delete_all(Mission)
  Repo.delete_all(Accounts.ChildProfile) 
  Repo.delete_all(Accounts.User)
end

# Create sample parent user
{:ok, parent} = Accounts.register_user(%{
  name: "Demo Parent",
  email: "parent@example.com",
  password: "password123"
})

IO.puts("Created parent user: #{parent.email}")

# Create sample child profiles
children_data = [
  %{name: "Emma", avatar_emoji: "🦄", birth_year: 2018, user_id: parent.id},
  %{name: "Alex", avatar_emoji: "🚀", birth_year: 2016, user_id: parent.id},
  %{name: "Sam", avatar_emoji: "🌟", birth_year: 2019, user_id: parent.id}
]

children = Enum.map(children_data, fn child_data ->
  {:ok, child} = Accounts.create_child_profile(child_data)
  IO.puts("Created child profile: #{child.name}")
  child
end)

# Sample missions for different types and difficulty levels
sample_missions = [
  # Level 1 - Easy Image Missions
  %{
    title: "Real Photo or AI Creation?",
    type: "real_or_fake_image",
    image_url: "https://picsum.photos/400/300?random=1",
    question_text: "Look at this picture carefully. Is this a real photo or was it created by a computer? 🤔",
    correct_answer: true,
    explanation: "✅ This is a real photo! You can tell because the lighting looks natural and all the details make sense together.",
    difficulty_level: 1,
    tags: ["beginner", "nature"]
  },
  %{
    title: "Cartoon or Real Animal?",
    type: "real_or_fake_image", 
    image_url: "https://picsum.photos/400/300?random=2",
    question_text: "Is this a real animal or a cartoon drawing? 🐱",
    correct_answer: false,
    explanation: "❌ This is a cartoon! Real animals don't have these perfect colors and shapes.",
    difficulty_level: 1,
    tags: ["beginner", "animals"]
  },
  %{
    title: "Real Food or Plastic?",
    type: "real_or_fake_image",
    image_url: "https://picsum.photos/400/300?random=3", 
    question_text: "Does this food look real enough to eat? 🍎",
    correct_answer: true,
    explanation: "✅ This is real food! You can see natural textures and realistic lighting.",
    difficulty_level: 1,
    tags: ["beginner", "food"]
  },

  # Level 2 - Medium Image Missions
  %{
    title: "AI Generated Portrait",
    type: "real_or_fake_image",
    image_url: "https://picsum.photos/400/300?random=4",
    question_text: "This person looks very realistic. But is this a real photo or AI-generated? 👤",
    correct_answer: false,
    explanation: "❌ This was created by AI! Look closely at the eyes and skin texture - they're too perfect and have subtle inconsistencies.",
    difficulty_level: 2,
    tags: ["intermediate", "people", "ai"]
  },
  %{
    title: "Edited vs Original Photo", 
    type: "real_or_fake_image",
    image_url: "https://picsum.photos/400/300?random=5",
    question_text: "This landscape photo looks amazing! Is it edited or completely natural? 🏔️",
    correct_answer: false,
    explanation: "❌ This photo has been heavily edited! The colors are too vibrant and the lighting doesn't match reality.",
    difficulty_level: 2,
    tags: ["intermediate", "landscape", "editing"]
  },
  %{
    title: "Real Product Photo",
    type: "real_or_fake_image",
    image_url: "https://picsum.photos/400/300?random=6",
    question_text: "This product photo looks professional. Is it a real photo or computer-generated? 📱",
    correct_answer: true,
    explanation: "✅ This is a real product photo! Professional photographers use special lighting to make products look their best.",
    difficulty_level: 2,
    tags: ["intermediate", "products"]
  },

  # Level 3 - Advanced Missions
  %{
    title: "Deepfake Detection",
    type: "real_or_fake_image",
    image_url: "https://picsum.photos/400/300?random=7",
    question_text: "This looks like a famous person in a movie scene. Is this real footage or a deepfake? 🎬",
    correct_answer: false,
    explanation: "❌ This is a deepfake! Advanced AI can now swap faces in videos, but look for unnatural eye movements and lighting inconsistencies.",
    difficulty_level: 3,
    tags: ["advanced", "deepfake", "celebrity"]
  },
  %{
    title: "News Image Verification",
    type: "real_or_fake_news",
    content_url: "https://example.com/news/unusual-weather",
    question_text: "This news image shows an unusual weather event. Is this a real news photo? 🌪️",
    correct_answer: false,
    explanation: "❌ This image has been manipulated! Always check multiple news sources and look for the original source of dramatic images.",
    difficulty_level: 3,
    tags: ["advanced", "news", "weather"]
  },

  # Story-based missions
  %{
    title: "Fact or Fiction News Story",
    type: "real_or_fake_story",
    content_url: "https://example.com/story1",
    question_text: "A news story says that scientists discovered chocolate that makes you smarter. Could this be real? 🍫",
    correct_answer: false,
    explanation: "❌ This is fake news! While chocolate has some benefits, no food can magically make you smarter. Always check scientific sources!",
    difficulty_level: 2,
    tags: ["intermediate", "science", "health"]
  },
  %{
    title: "Real Historical Event",
    type: "real_or_fake_story",
    content_url: "https://example.com/story2", 
    question_text: "Did people really once think the Earth was flat? 🌍",
    correct_answer: true,
    explanation: "✅ Yes! Long ago, many people believed the Earth was flat. Science and exploration helped us learn the truth about our round planet!",
    difficulty_level: 2,
    tags: ["intermediate", "history", "science"]
  },

  # Pre-reader missions for kids who can't read yet
  %{
    title: "Find the Silly Dog!",
    type: "spot_the_silly_thing",
    image_url: "https://example.com/audio-missions/dog-with-sunglasses.jpg",
    question_text: "Tap on the silly thing in this picture!",
    correct_answer: nil,
    explanation: "Dogs don't wear sunglasses! That's silly! Real dogs use their eyes to see, just like you do. The sunglasses are what makes this picture funny and not real.",
    difficulty_level: 1,
    tags: ["silly", "animals", "prereader", "beginner"],
    prompt_audio_url: "https://example.com/audio-missions/dog-sunglasses-prompt.mp3",
    explanation_audio_url: "https://example.com/audio-missions/dog-sunglasses-explanation.mp3",
    emoji_hint: "🕶️",
    choices: [
      %{
        "id" => "sunglasses",
        "type" => "clickable_area",
        "coordinates" => %{"x" => 150, "y" => 80, "width" => 60, "height" => 25},
        "label" => "sunglasses",
        "is_correct" => true
      },
      %{
        "id" => "nose",
        "type" => "clickable_area", 
        "coordinates" => %{"x" => 180, "y" => 120, "width" => 20, "height" => 15},
        "label" => "nose",
        "is_correct" => false
      },
      %{
        "id" => "ears",
        "type" => "clickable_area",
        "coordinates" => %{"x" => 120, "y" => 60, "width" => 40, "height" => 30}, 
        "label" => "ears",
        "is_correct" => false
      }
    ],
    created_by_ai: true
  },
  %{
    title: "What Animal Makes This Sound?",
    type: "match_sound_to_image",
    audio_url: "https://example.com/audio-missions/cow-moo-sound.mp3",
    question_text: "Listen to the sound and tap the right animal!",
    correct_answer: nil,
    explanation: "That's the sound a cow makes! Cows say 'moo' when they talk to other cows or when they want food. Cows live on farms and give us milk to drink.",
    difficulty_level: 1,
    tags: ["animals", "sounds", "prereader", "farm"],
    prompt_audio_url: "https://example.com/audio-missions/match-sound-prompt.mp3", 
    explanation_audio_url: "https://example.com/audio-missions/cow-explanation.mp3",
    emoji_hint: "🐄",
    choices: [
      %{
        "id" => "cow",
        "type" => "image_choice",
        "image_url" => "https://example.com/audio-missions/cow-choice.jpg",
        "label" => "cow",
        "is_correct" => true
      },
      %{
        "id" => "pig", 
        "type" => "image_choice",
        "image_url" => "https://example.com/audio-missions/pig-choice.jpg",
        "label" => "pig", 
        "is_correct" => false
      },
      %{
        "id" => "sheep",
        "type" => "image_choice", 
        "image_url" => "https://example.com/audio-missions/sheep-choice.jpg",
        "label" => "sheep",
        "is_correct" => false
      }
    ],
    created_by_ai: true
  }
]

# Insert sample missions
Enum.each(sample_missions, fn mission_data ->
  {:ok, mission} = Missions.create_mission(mission_data)
  IO.puts("Created mission: #{mission.title}")
end)

# Create some sample submissions for the first child to show progress
[emma | _] = children
missions = Missions.list_missions()

# Emma completes some missions with varying success
sample_submissions = [
  {Enum.at(missions, 0), true, 3000},   # Correct, 3 seconds
  {Enum.at(missions, 1), false, 5000},  # Wrong, 5 seconds  
  {Enum.at(missions, 2), true, 4000},   # Correct, 4 seconds
  {Enum.at(missions, 3), true, 8000},   # Correct, 8 seconds
]

Enum.each(sample_submissions, fn {mission, answer, time_ms} ->
  case Missions.submit_mission_answer(emma.id, mission.id, answer, time_ms) do
    {:ok, submission} -> 
      IO.puts("Created submission for #{emma.name}: #{if submission.is_correct, do: "✓", else: "✗"}")
    {:error, _} ->
      IO.puts("Submission already exists or failed")
  end
end)

IO.puts("\n🎉 Database seeded successfully!")
IO.puts("👤 Parent login: parent@example.com / password123")
IO.puts("👶 Children: Emma (🦄), Alex (🚀), Sam (🌟)")
IO.puts("🎯 #{length(sample_missions)} missions created")
IO.puts("📊 Sample progress data created for Emma")
IO.puts("\nStart the server with: mix phx.server")
IO.puts("API available at: http://localhost:4000/api/v1")