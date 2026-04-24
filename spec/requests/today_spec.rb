require "rails_helper"

RSpec.describe "Today", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  context "with an active plan covering today" do
    let(:plan) do
      create(:meal_plan, owner: user, assignee: user,
             start_date: Date.current - 1, end_date: Date.current + 5)
    end
    let!(:day) { plan.plan_days.create!(date: Date.current) }
    let!(:breakfast) { day.meals.create!(meal_type: :breakfast, position: 0, time: "08:00") }

    it "shows today's meals and a daily note form" do
      breakfast.meal_items.create!(description: "Avena con fruta", position: 0)
      get today_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Avena con fruta", "Cómo te fue hoy", "Comí", "Modifiqué", "Skip")
    end
  end

  context "without an active plan" do
    it "shows the empty state with a link to create a plan" do
      get today_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("No tienes un plan activo hoy")
    end
  end

  context "with a plan whose range excludes today" do
    it "shows the 'no day' state" do
      create(:meal_plan, owner: user, assignee: user,
             start_date: Date.current - 14, end_date: Date.current - 7)
      get today_path
      expect(response).to have_http_status(:ok)
      # because active_on fails, it falls back to the no-plan state
      expect(response.body).to include("No tienes un plan activo hoy")
    end
  end
end
