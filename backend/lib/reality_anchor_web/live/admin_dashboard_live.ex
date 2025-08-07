defmodule RealityAnchorWeb.AdminDashboardLive do
  use RealityAnchorWeb, :live_view
  import Ecto.Query
  
  alias RealityAnchor.{Accounts, Missions, Repo}
  alias RealityAnchor.Missions.{Mission, Submission}
  
  @impl true
  def mount(_params, _session, socket) do
    # TODO: Add proper admin authentication check
    # if connected?(socket), do: verify_admin_user(socket)
    
    socket =
      socket
      |> assign(:page_title, "Admin Dashboard")
      |> load_dashboard_data()
    
    {:ok, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Admin Dashboard")
  end

  defp apply_action(socket, :missions, _params) do
    socket
    |> assign(:page_title, "Missions Management")
    |> assign(:missions, list_missions())
  end

  defp apply_action(socket, :submissions, _params) do
    socket
    |> assign(:page_title, "Recent Submissions")
    |> assign(:submissions, list_recent_submissions())
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50">
      <div class="bg-white shadow">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center py-6">
            <div class="flex items-center">
              <h1 class="text-3xl font-bold text-gray-900">Reality Anchor Admin</h1>
            </div>
            <nav class="flex space-x-4">
              <.link 
                patch={~p"/admin"} 
                class={nav_link_class(@live_action == :index)}
              >
                Dashboard
              </.link>
              <.link 
                patch={~p"/admin/missions"} 
                class={nav_link_class(@live_action == :missions)}
              >
                Missions
              </.link>
              <.link 
                patch={~p"/admin/submissions"} 
                class={nav_link_class(@live_action == :submissions)}
              >
                Submissions
              </.link>
            </nav>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        <%= case @live_action do %>
          <% :index -> %>
            <.dashboard_overview stats={@stats} />
            
          <% :missions -> %>
            <.missions_management missions={@missions} />
            
          <% :submissions -> %>
            <.submissions_list submissions={@submissions} />
        <% end %>
      </div>
    </div>
    """
  end

  defp dashboard_overview(assigns) do
    ~H"""
    <div>
      <!-- Stats Cards -->
      <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-blue-500 rounded-md flex items-center justify-center">
                  <span class="text-white font-semibold">👨‍👩‍👧‍👦</span>
                </div>
              </div>
              <div class="ml-5">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Parents</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @stats.total_parents %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-green-500 rounded-md flex items-center justify-center">
                  <span class="text-white font-semibold">👶</span>
                </div>
              </div>
              <div class="ml-5">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Children</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @stats.total_children %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-purple-500 rounded-md flex items-center justify-center">
                  <span class="text-white font-semibold">🎯</span>
                </div>
              </div>
              <div class="ml-5">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Active Missions</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @stats.active_missions %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div class="bg-white overflow-hidden shadow rounded-lg">
          <div class="p-5">
            <div class="flex items-center">
              <div class="flex-shrink-0">
                <div class="w-8 h-8 bg-yellow-500 rounded-md flex items-center justify-center">
                  <span class="text-white font-semibold">📊</span>
                </div>
              </div>
              <div class="ml-5">
                <dl>
                  <dt class="text-sm font-medium text-gray-500 truncate">Total Submissions</dt>
                  <dd class="text-lg font-medium text-gray-900"><%= @stats.total_submissions %></dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="bg-white shadow overflow-hidden sm:rounded-md">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Recent Activity</h3>
          <div class="flow-root">
            <ul class="-mb-8">
              <%= for {activity, index} <- Enum.with_index(@stats.recent_activities) do %>
                <li class={if index < length(@stats.recent_activities) - 1, do: "pb-8", else: ""}>
                  <div class="relative">
                    <%= if index < length(@stats.recent_activities) - 1 do %>
                      <span class="absolute top-4 left-4 -ml-px h-full w-0.5 bg-gray-200" aria-hidden="true"></span>
                    <% end %>
                    <div class="relative flex space-x-3">
                      <div class="h-8 w-8 rounded-full bg-blue-500 flex items-center justify-center">
                        <span class="text-white text-sm">📝</span>
                      </div>
                      <div class="min-w-0 flex-1 pt-1.5">
                        <div>
                          <p class="text-sm text-gray-500">
                            <%= activity.description %>
                            <time class="font-medium text-gray-900">
                              <%= Calendar.strftime(activity.timestamp, "%m/%d %I:%M %p") %>
                            </time>
                          </p>
                        </div>
                      </div>
                    </div>
                  </div>
                </li>
              <% end %>
            </ul>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp missions_management(assigns) do
    ~H"""
    <div class="bg-white shadow overflow-hidden sm:rounded-md">
      <div class="px-4 py-5 sm:p-6">
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-lg leading-6 font-medium text-gray-900">Missions Management</h3>
          <button 
            type="button" 
            class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
          >
            Add New Mission
          </button>
        </div>
        
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Title</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Type</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Difficulty</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Submissions</th>
                <th class="relative px-6 py-3"><span class="sr-only">Actions</span></th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for mission <- @missions do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= mission.title %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800">
                      <%= mission.type %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    Level <%= mission.difficulty_level %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <%= if mission.is_active do %>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        Active
                      </span>
                    <% else %>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800">
                        Inactive
                      </span>
                    <% end %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= mission.submission_count || 0 %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <button class="text-blue-600 hover:text-blue-900 mr-2">Edit</button>
                    <button class="text-red-600 hover:text-red-900">Delete</button>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp submissions_list(assigns) do
    ~H"""
    <div class="bg-white shadow overflow-hidden sm:rounded-md">
      <div class="px-4 py-5 sm:p-6">
        <h3 class="text-lg leading-6 font-medium text-gray-900 mb-4">Recent Submissions</h3>
        
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Child</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mission</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Answer</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Result</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Time</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <%= for submission <- @submissions do %>
                <tr>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= submission.child_profile.name %>
                    <span class="text-xs text-gray-500">(<%= submission.child_profile.avatar_emoji %>)</span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= String.slice(submission.mission.title, 0, 40) %><%= if String.length(submission.mission.title) > 40, do: "..." %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= if submission.selected_answer, do: "Real", else: "Fake" %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <%= if submission.is_correct do %>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                        ✓ Correct
                      </span>
                    <% else %>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                        ✗ Incorrect
                      </span>
                    <% end %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= Float.round(submission.time_spent_ms / 1000, 1) %>s
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= Calendar.strftime(submission.inserted_at, "%m/%d %I:%M %p") %>
                  </td>
                </tr>
              <% end %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    """
  end

  defp nav_link_class(true), do: "bg-blue-100 text-blue-700 px-3 py-2 rounded-md text-sm font-medium"
  defp nav_link_class(false), do: "text-gray-500 hover:text-gray-700 px-3 py-2 rounded-md text-sm font-medium"

  defp load_dashboard_data(socket) do
    stats = %{
      total_parents: Repo.aggregate(Accounts.User, :count),
      total_children: Repo.aggregate(Accounts.ChildProfile, :count),
      active_missions: Repo.aggregate(from(m in Mission, where: m.is_active == true), :count),
      total_submissions: Repo.aggregate(Submission, :count),
      recent_activities: get_recent_activities()
    }
    
    assign(socket, :stats, stats)
  end

  defp list_missions do
    from(m in Mission,
         left_join: s in assoc(m, :submissions),
         group_by: m.id,
         select: %{m | submission_count: count(s.id)},
         order_by: [desc: m.inserted_at],
         limit: 50)
    |> Repo.all()
  end

  defp list_recent_submissions do
    from(s in Submission,
         join: c in assoc(s, :child_profile),
         join: m in assoc(s, :mission),
         order_by: [desc: s.inserted_at],
         limit: 20,
         preload: [child_profile: c, mission: m])
    |> Repo.all()
  end

  defp get_recent_activities do
    # TODO: Implement proper activity logging
    # For now, return recent submissions as activities
    recent_submissions = 
      from(s in Submission,
           join: c in assoc(s, :child_profile),
           join: m in assoc(s, :mission),
           order_by: [desc: s.inserted_at],
           limit: 10,
           select: {c.name, m.title, s.is_correct, s.inserted_at})
      |> Repo.all()
    
    Enum.map(recent_submissions, fn {child_name, mission_title, is_correct, timestamp} ->
      result = if is_correct, do: "correctly", else: "incorrectly"
      %{
        description: "#{child_name} answered #{String.slice(mission_title, 0, 30)}... #{result}",
        timestamp: timestamp
      }
    end)
  end
end