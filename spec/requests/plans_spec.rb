require "rails_helper"

RSpec.describe "Plans", type: :request do
  let(:user) { create(:user) }
  before { sign_in user }

  describe "GET /plans" do
    it "lists the user's plans" do
      create(:meal_plan, owner: user, assignee: user, name: "Mi semana")
      get plans_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mi semana")
    end
  end

  describe "POST /plans" do
    let(:params) do
      {
        meal_plan: {
          name: "Semana prueba",
          start_date: Date.current.to_s,
          end_date:   (Date.current + 6.days).to_s
        }
      }
    end

    it "creates the plan and generates a 7×4 skeleton" do
      expect {
        post plans_path, params: params
      }.to change(MealPlan, :count).by(1)
       .and change(PlanDay, :count).by(7)
       .and change(Meal, :count).by(28)

      plan = MealPlan.last
      expect(plan.owner).to eq(user)
      expect(plan.assignee).to eq(user)
      expect(plan.plan_days.count).to eq(7)
      expect(plan.plan_days.first.meals.map(&:meal_type)).to match_array(%w[breakfast lunch dinner snack])
      expect(response).to redirect_to(edit_plan_path(plan))
    end

    it "re-renders the form on validation errors" do
      post plans_path, params: { meal_plan: { name: "", start_date: "", end_date: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /plans/:id/edit" do
    it "renders the grid with all meals" do
      plan = create_plan_with_skeleton
      get edit_plan_path(plan)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Desayuno", "Comida", "Cena", "Colación")
    end
  end

  describe "GET /plans/:id" do
    it "returns 404 for plans owned by someone else" do
      other = create(:user)
      plan  = create(:meal_plan, owner: other, assignee: other)
      get plan_path(plan)
      expect(response).to have_http_status(:not_found)
    end
  end

  def create_plan_with_skeleton
    plan = create(:meal_plan, owner: user, assignee: user)
    (plan.start_date..plan.end_date).each do |date|
      day = plan.plan_days.create!(date: date)
      Meal.meal_types.keys.each_with_index do |type, idx|
        day.meals.create!(meal_type: type, time: "08:00", position: idx)
      end
    end
    plan
  end
end
