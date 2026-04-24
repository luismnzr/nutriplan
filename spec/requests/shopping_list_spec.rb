require "rails_helper"

RSpec.describe "Shopping list", type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:meal_plan, owner: user, assignee: user) }
  let(:day)  { plan.plan_days.create!(date: plan.start_date) }
  let(:meal) { day.meals.create!(meal_type: :breakfast, position: 0) }

  before do
    meal.meal_items.create!(description: "Avena", quantity: "1 taza", position: 0)
    meal.meal_items.create!(description: "Avena", quantity: "2 taza", position: 1)
    meal.meal_items.create!(description: "Leche", quantity: "200 g", position: 2)
    sign_in user
  end

  describe "GET /plans/:id/shopping_list" do
    it "renders aggregated items" do
      get shopping_list_plan_path(plan)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Avena", "3 taza", "Leche", "200 g")
    end
  end

  describe "POST /plans/:id/shopping_list_checks/toggle" do
    it "creates a check on first call and destroys it on the second" do
      expect {
        post toggle_shopping_list_check_plan_path(plan, item_key: "avena"),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change { plan.shopping_list_checks.count }.by(1)

      expect(response.media_type).to eq(Mime[:turbo_stream])

      expect(response.media_type).to eq(Mime[:turbo_stream])

      expect {
        post toggle_shopping_list_check_plan_path(plan, item_key: "avena"),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change { plan.shopping_list_checks.count }.by(-1)
    end

    it "is not found for plans owned by another user" do
      other = create(:user)
      other_plan = create(:meal_plan, owner: other, assignee: other)
      post toggle_shopping_list_check_plan_path(other_plan, item_key: "x"),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }
      expect(response).to have_http_status(:not_found)
    end
  end
end
