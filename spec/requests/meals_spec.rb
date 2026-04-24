require "rails_helper"

RSpec.describe "Meals", type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:meal_plan, owner: user, assignee: user) }
  let(:day)  { plan.plan_days.create!(date: plan.start_date) }

  before do
    # seed the three fixed meals so "+ snack" adds a 4th with position=3 (or higher)
    %i[breakfast lunch dinner].each_with_index do |type, idx|
      day.meals.create!(meal_type: type, position: idx, time: "08:00")
    end
    day.meals.create!(meal_type: :snack, position: 3, time: "17:00")
    sign_in user
  end

  describe "POST /plans/:plan_id/meals" do
    it "creates an extra snack for a day with next position" do
      expect {
        post plan_meals_path(plan),
             params: { meal: { plan_day_id: day.id, meal_type: "snack" } },
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change { day.meals.count }.by(1)

      extra = day.meals.where(meal_type: :snack).order(:position).last
      expect(extra.position).to eq(4)
      expect(response.body).to include("append")
    end
  end

  describe "DELETE /meals/:id" do
    it "removes the meal" do
      snack = day.meals.where(meal_type: :snack).first
      expect {
        delete meal_path(snack),
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(Meal, :count).by(-1)
    end
  end
end
