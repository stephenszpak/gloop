defmodule RealityAnchor.Factory do
  use ExMachina.Ecto, repo: RealityAnchor.Repo

  def user_factory do
    %RealityAnchor.Accounts.User{
      name: sequence(:name, &"User #{&1}"),
      email: sequence(:email, &"user#{&1}@example.com"),
      password_hash: Bcrypt.hash_pwd_salt("password123")
    }
  end

  def child_profile_factory do
    %RealityAnchor.Accounts.ChildProfile{
      name: sequence(:name, &"Child #{&1}"),
      avatar_emoji: sequence(:avatar, ["🧒", "👦", "👧", "🦄", "🚀", "🌟"]),
      birth_year: sequence(:birth_year, [2016, 2017, 2018, 2019, 2020]),
      user: build(:user)
    }
  end

  def mission_factory do
    %RealityAnchor.Missions.Mission{
      title: sequence(:title, &"Mission #{&1}"),
      type: "real_or_fake_image",
      image_url: sequence(:image_url, &"https://picsum.photos/400/300?random=#{&1}"),
      question_text: "Is this image real or fake?",
      correct_answer: sequence(:answer, [true, false]),
      explanation: "This is an explanation of why the answer is correct.",
      difficulty_level: sequence(:difficulty, [1, 2, 3]),
      is_active: true,
      tags: ["test", "sample"]
    }
  end

  def submission_factory do
    mission = build(:mission)
    
    %RealityAnchor.Missions.Submission{
      selected_answer: sequence(:selected, [true, false]),
      is_correct: sequence(:correct, [true, false]),
      time_spent_ms: sequence(:time, [1000, 2000, 3000, 4000, 5000]),
      child_profile: build(:child_profile),
      mission: mission
    }
  end

  # Trait helpers
  def with_children(%RealityAnchor.Accounts.User{} = user, count \\ 2) do
    children = insert_list(count, :child_profile, user: user)
    %{user | child_profiles: children}
  end

  def difficulty_level(factory_name, level) when level in 1..5 do
    build(factory_name, difficulty_level: level)
  end

  def correct_submission(factory_name) do
    build(factory_name, selected_answer: true, is_correct: true)
  end

  def incorrect_submission(factory_name) do  
    build(factory_name, selected_answer: false, is_correct: false)
  end
end