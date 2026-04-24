require "rails_helper"

RSpec.describe "MealLogs", type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:meal_plan, owner: user, assignee: user) }
  let(:day)  { plan.plan_days.create!(date: Date.current) }
  let(:meal) { day.meals.create!(meal_type: :breakfast, position: 0, time: "08:00") }

  before { sign_in user }

  describe "POST /meals/:meal_id/meal_log" do
    it "creates a log when none exists" do
      expect {
        post meal_meal_log_path(meal),
             params: { meal_log: { status: "eaten" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(MealLog, :count).by(1)

      log = meal.reload.meal_log
      expect(log.status).to eq("eaten")
      expect(log.logged_at).to be_present
      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include("replace")
    end

    it "overwrites an existing log (unique per meal)" do
      meal.create_meal_log!(status: :eaten, logged_at: 2.hours.ago)
      expect {
        post meal_meal_log_path(meal),
             params: { meal_log: { status: "skipped" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.not_to change(MealLog, :count)

      expect(meal.reload.meal_log.status).to eq("skipped")
    end

    it "records modified status with actual_description from swap chip" do
      item = meal.meal_items.create!(description: "Avena", swap_options: ["Yogurt con granola"], position: 0)
      post meal_meal_log_path(meal),
           params: { meal_log: { status: "modified", actual_description: item.swap_options.first } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      log = meal.reload.meal_log
      expect(log.status).to eq("modified")
      expect(log.actual_description).to eq("Yogurt con granola")
    end

    it "is forbidden for meals owned by another user" do
      other = create(:user)
      other_plan = create(:meal_plan, owner: other, assignee: other)
      other_day  = other_plan.plan_days.create!(date: Date.current)
      other_meal = other_day.meals.create!(meal_type: :lunch, position: 0)

      post meal_meal_log_path(other_meal),
           params: { meal_log: { status: "eaten" } },
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
