require "rails_helper"

RSpec.describe "History", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /history" do
    it "renders the current month by default" do
      get history_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Puntuación diaria", "Cumplimiento")
    end

    it "accepts a ?month=YYYY-MM parameter" do
      get history_path(month: "2025-01")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Enero 2025")
    end

    it "falls back to current month on invalid input" do
      get history_path(month: "not-a-date")
      expect(response).to have_http_status(:ok)
    end

    it "shows scores and compliance for days with activity" do
      plan = create(:meal_plan, owner: user, assignee: user,
                    start_date: Date.current, end_date: Date.current + 1)
      day = plan.plan_days.create!(date: Date.current)
      m1 = day.meals.create!(meal_type: :breakfast, position: 0)
      m2 = day.meals.create!(meal_type: :lunch, position: 1)
      m1.create_meal_log!(status: :eaten,    logged_at: Time.current)
      m2.create_meal_log!(status: :modified, logged_at: Time.current)
      user.daily_notes.create!(plan_day: day, overall_score: 5)

      get history_path
      expect(response.body).to include("2/2") # compliance
    end
  end
end
