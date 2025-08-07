defmodule RealityAnchor.MissionsTest do
  use RealityAnchor.DataCase
  import RealityAnchor.Factory

  alias RealityAnchor.Missions
  alias RealityAnchor.Missions.{Mission, Submission}

  describe "missions" do
    @valid_attrs %{
      title: "Test Mission",
      type: "real_or_fake_image",
      image_url: "https://example.com/image.jpg",
      question_text: "Is this real?",
      correct_answer: true,
      explanation: "This is the explanation",
      difficulty_level: 2
    }
    @invalid_attrs %{title: nil, question_text: nil, correct_answer: nil}

    test "create_mission/1 with valid data creates a mission" do
      assert {:ok, %Mission{} = mission} = Missions.create_mission(@valid_attrs)
      assert mission.title == "Test Mission"
      assert mission.type == "real_or_fake_image"
      assert mission.correct_answer == true
    end

    test "create_mission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Missions.create_mission(@invalid_attrs)
    end

    test "get_next_mission_for_child/1 returns appropriate mission" do
      child = insert(:child_profile)
      mission = insert(:mission, difficulty_level: 1, is_active: true)
      
      assert {:ok, returned_mission} = Missions.get_next_mission_for_child(child.id)
      assert returned_mission.id == mission.id
    end

    test "get_next_mission_for_child/1 excludes completed missions" do
      child = insert(:child_profile)
      mission1 = insert(:mission, difficulty_level: 1)
      mission2 = insert(:mission, difficulty_level: 1)
      
      # Child completes mission1
      insert(:submission, child_profile: child, mission: mission1)
      
      assert {:ok, returned_mission} = Missions.get_next_mission_for_child(child.id)
      assert returned_mission.id == mission2.id
    end

    test "get_next_mission_for_child/1 returns error when no missions available" do
      child = insert(:child_profile)
      
      assert {:error, :no_missions_available} = Missions.get_next_mission_for_child(child.id)
    end

    test "calculate_difficulty_level/1 adjusts based on child age" do
      young_child = insert(:child_profile, birth_year: Date.utc_today().year - 5)
      older_child = insert(:child_profile, birth_year: Date.utc_today().year - 8)
      
      assert Missions.calculate_difficulty_level(young_child) == 1
      assert Missions.calculate_difficulty_level(older_child) == 3
    end
  end

  describe "submissions" do
    test "submit_mission_answer/4 creates submission with correct answer" do
      child = insert(:child_profile)
      mission = insert(:mission, correct_answer: true)
      
      assert {:ok, %Submission{} = submission} = 
        Missions.submit_mission_answer(child.id, mission.id, true, 5000)
      
      assert submission.selected_answer == true
      assert submission.is_correct == true
      assert submission.time_spent_ms == 5000
    end

    test "submit_mission_answer/4 creates submission with incorrect answer" do
      child = insert(:child_profile)
      mission = insert(:mission, correct_answer: true)
      
      assert {:ok, %Submission{} = submission} = 
        Missions.submit_mission_answer(child.id, mission.id, false, 3000)
      
      assert submission.selected_answer == false
      assert submission.is_correct == false
    end

    test "submit_mission_answer/4 prevents duplicate submissions" do
      child = insert(:child_profile)
      mission = insert(:mission)
      
      assert {:ok, _submission} = 
        Missions.submit_mission_answer(child.id, mission.id, true, 1000)
      
      assert {:error, %Ecto.Changeset{}} = 
        Missions.submit_mission_answer(child.id, mission.id, false, 2000)
    end

    test "get_child_progress/1 returns accurate statistics" do
      child = insert(:child_profile)
      mission1 = insert(:mission, correct_answer: true)
      mission2 = insert(:mission, correct_answer: false)
      
      # Child gets first mission correct, second incorrect
      insert(:submission, child_profile: child, mission: mission1, 
             selected_answer: true, is_correct: true)
      insert(:submission, child_profile: child, mission: mission2, 
             selected_answer: true, is_correct: false)
      
      progress = Missions.get_child_progress(child.id)
      
      assert progress.total_missions == 2
      assert progress.correct_missions == 1
      assert progress.accuracy == 50.0
    end

    test "Submission.accuracy_for_child/1 calculates correct percentage" do
      child = insert(:child_profile)
      
      # 3 correct out of 4 total = 75%
      insert_list(3, :submission, child_profile: child, is_correct: true)
      insert(:submission, child_profile: child, is_correct: false)
      
      assert Submission.accuracy_for_child(child.id) == 75.0
    end

    test "Submission.current_streak_for_child/1 counts consecutive correct answers" do
      child = insert(:child_profile)
      
      # Most recent submissions: correct, correct, incorrect, correct
      # Should return streak of 2
      old_submission = insert(:submission, child_profile: child, is_correct: true)
      insert(:submission, child_profile: child, is_correct: false)
      insert(:submission, child_profile: child, is_correct: true)  
      insert(:submission, child_profile: child, is_correct: true)
      
      # Update timestamps to ensure proper ordering
      Repo.update_all(
        from(s in Submission, where: s.id == ^old_submission.id),
        set: [inserted_at: ~N[2024-01-01 00:00:00]]
      )
      
      assert Submission.current_streak_for_child(child.id) == 2
    end
  end

  describe "mission filtering" do
    test "Mission.for_difficulty/2 filters by difficulty level" do
      insert(:mission, difficulty_level: 1)
      insert(:mission, difficulty_level: 3)
      insert(:mission, difficulty_level: 5)
      
      level_2_missions = Mission |> Mission.for_difficulty(2) |> Repo.all()
      
      assert length(level_2_missions) == 1
      assert hd(level_2_missions).difficulty_level == 1
    end

    test "Mission.active/1 filters active missions only" do
      insert(:mission, is_active: true)
      insert(:mission, is_active: false)
      
      active_missions = Mission |> Mission.active() |> Repo.all()
      
      assert length(active_missions) == 1
      assert hd(active_missions).is_active == true
    end

    test "Mission.of_type/2 filters by mission type" do
      insert(:mission, type: "real_or_fake_image")
      insert(:mission, type: "real_or_fake_story")
      
      image_missions = Mission |> Mission.of_type("real_or_fake_image") |> Repo.all()
      
      assert length(image_missions) == 1
      assert hd(image_missions).type == "real_or_fake_image"
    end
  end
end