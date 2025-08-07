defmodule RealityAnchorWeb.API.MissionControllerTest do
  use RealityAnchorWeb.ConnCase
  import RealityAnchor.Factory

  alias RealityAnchor.Guardian

  setup %{conn: conn} do
    user = insert(:user)
    child = insert(:child_profile, user: user)
    {:ok, token, _claims} = Guardian.encode_and_sign(user)
    
    conn = put_req_header(conn, "authorization", "Bearer #{token}")
    {:ok, conn: conn, user: user, child: child}
  end

  describe "GET /api/v1/missions/next" do
    test "returns next mission for child", %{conn: conn, child: child} do
      mission = insert(:mission, difficulty_level: 1, is_active: true)

      conn = get(conn, ~p"/api/v1/missions/next", %{"child_id" => child.id})

      assert %{
        "data" => %{
          "id" => mission_id,
          "title" => title,
          "type" => type,
          "question_text" => question,
          "difficulty_level" => difficulty
        }
      } = json_response(conn, 200)

      assert mission_id == mission.id
      assert title == mission.title
      assert type == mission.type
      assert question == mission.question_text
      assert difficulty == mission.difficulty_level
      
      # Should not expose correct answer before submission
      response_data = json_response(conn, 200)["data"]
      refute Map.has_key?(response_data, "correct_answer")
      refute Map.has_key?(response_data, "explanation")
    end

    test "returns 404 when no missions available", %{conn: conn, child: child} do
      conn = get(conn, ~p"/api/v1/missions/next", %{"child_id" => child.id})

      assert %{"error" => %{"message" => "No missions available for this child"}} = 
        json_response(conn, 404)
    end

    test "returns 401 when child doesn't belong to user", %{conn: conn} do
      other_child = insert(:child_profile)
      insert(:mission)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/missions/next", %{"child_id" => other_child.id})
      end
    end

    test "excludes already completed missions", %{conn: conn, child: child} do
      mission1 = insert(:mission, title: "Completed Mission", difficulty_level: 1)
      mission2 = insert(:mission, title: "Available Mission", difficulty_level: 1)
      
      # Child completes mission1
      insert(:submission, child_profile: child, mission: mission1)

      conn = get(conn, ~p"/api/v1/missions/next", %{"child_id" => child.id})

      assert %{"data" => %{"title" => "Available Mission"}} = json_response(conn, 200)
    end
  end

  describe "POST /api/v1/missions/:id/submit" do
    test "creates submission with correct answer", %{conn: conn, child: child} do
      mission = insert(:mission, correct_answer: true)
      
      submit_attrs = %{
        "child_id" => child.id,
        "selected_answer" => true,
        "time_spent_ms" => 5000
      }

      conn = post(conn, ~p"/api/v1/missions/#{mission.id}/submit", submit_attrs)

      assert %{
        "data" => %{
          "submission" => submission,
          "mission" => mission_data,
          "result" => result
        }
      } = json_response(conn, 201)

      assert submission["selected_answer"] == true
      assert submission["is_correct"] == true
      assert submission["time_spent_ms"] == 5000
      
      assert mission_data["correct_answer"] == true
      assert mission_data["explanation"]
      
      assert result["is_correct"] == true
      assert result["explanation"]
    end

    test "creates submission with incorrect answer", %{conn: conn, child: child} do
      mission = insert(:mission, correct_answer: true)
      
      submit_attrs = %{
        "child_id" => child.id,
        "selected_answer" => false,
        "time_spent_ms" => 3000
      }

      conn = post(conn, ~p"/api/v1/missions/#{mission.id}/submit", submit_attrs)

      assert %{
        "data" => %{
          "submission" => %{"is_correct" => false},
          "result" => %{"is_correct" => false}
        }
      } = json_response(conn, 201)
    end

    test "prevents duplicate submissions", %{conn: conn, child: child} do
      mission = insert(:mission)
      insert(:submission, child_profile: child, mission: mission)
      
      submit_attrs = %{
        "child_id" => child.id,
        "selected_answer" => true,
        "time_spent_ms" => 1000
      }

      conn = post(conn, ~p"/api/v1/missions/#{mission.id}/submit", submit_attrs)

      assert %{"error" => %{"message" => "Validation failed"}} = json_response(conn, 422)
    end

    test "returns 401 when child doesn't belong to user", %{conn: conn} do
      mission = insert(:mission)
      other_child = insert(:child_profile)
      
      submit_attrs = %{
        "child_id" => other_child.id,
        "selected_answer" => true
      }

      assert_error_sent 404, fn ->
        post(conn, ~p"/api/v1/missions/#{mission.id}/submit", submit_attrs)
      end
    end

    test "returns 404 for non-existent mission", %{conn: conn, child: child} do
      submit_attrs = %{
        "child_id" => child.id,
        "selected_answer" => true
      }

      assert_error_sent 404, fn ->
        post(conn, ~p"/api/v1/missions/999999/submit", submit_attrs)
      end
    end
  end

  describe "GET /api/v1/missions" do
    test "lists active missions", %{conn: conn} do
      active_mission = insert(:mission, is_active: true)
      insert(:mission, is_active: false)

      conn = get(conn, ~p"/api/v1/missions")

      assert %{"data" => missions} = json_response(conn, 200)
      assert length(missions) == 1
      assert hd(missions)["id"] == active_mission.id
    end

    test "supports filtering by type", %{conn: conn} do
      insert(:mission, type: "real_or_fake_image")
      insert(:mission, type: "real_or_fake_story")

      conn = get(conn, ~p"/api/v1/missions", %{"type" => "real_or_fake_image"})

      assert %{"data" => missions} = json_response(conn, 200)
      assert length(missions) == 1
      assert hd(missions)["type"] == "real_or_fake_image"
    end

    test "supports limit parameter", %{conn: conn} do
      insert_list(5, :mission)

      conn = get(conn, ~p"/api/v1/missions", %{"limit" => "2"})

      assert %{"data" => missions} = json_response(conn, 200)
      assert length(missions) == 2
    end
  end

  describe "authentication required" do
    test "returns 401 without token" do
      conn = build_conn()
      child = insert(:child_profile)

      conn = get(conn, ~p"/api/v1/missions/next", %{"child_id" => child.id})

      assert %{"error" => %{"message" => "Authentication required"}} = json_response(conn, 401)
    end

    test "returns 401 with invalid token" do
      conn = 
        build_conn()
        |> put_req_header("authorization", "Bearer invalid.token")
      
      child = insert(:child_profile)
      conn = get(conn, ~p"/api/v1/missions/next", %{"child_id" => child.id})

      assert %{"error" => %{"message" => "Invalid token"}} = json_response(conn, 401)
    end
  end
end