require "rails_helper"

RSpec.describe "MealItems", type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:meal_plan, owner: user, assignee: user) }
  let(:day)  { plan.plan_days.create!(date: plan.start_date) }
  let(:meal) { day.meals.create!(meal_type: :breakfast, position: 0, time: "08:00") }

  before { sign_in user }

  describe "POST /meals/:meal_id/meal_items" do
    it "creates a meal_item with a turbo-stream append response" do
      expect {
        post meal_meal_items_path(meal),
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(MealItem, :count).by(1)

      expect(response.media_type).to eq(Mime[:turbo_stream])
      expect(response.body).to include("turbo-stream")
      expect(response.body).to include("append")
      expect(MealItem.last.description).to eq("Nuevo alimento")
    end

    it "denies access to meals from another owner" do
      other = create(:user)
      other_plan = create(:meal_plan, owner: other, assignee: other)
      other_day  = other_plan.plan_days.create!(date: other_plan.start_date)
      other_meal = other_day.meals.create!(meal_type: :lunch, position: 0)

      post meal_meal_items_path(other_meal),
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /meal_items/:id" do
    let!(:item) { meal.meal_items.create!(description: "Avena", position: 0) }

    it "updates attributes and replaces the frame via turbo-stream" do
      patch meal_item_path(item),
            params: {
              meal_item: {
                description: "Avena con plátano",
                quantity:    "1 taza",
                swap_options: "Yogurt\nPan integral"
              }
            },
            headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to be_successful
      expect(response.media_type).to eq(Mime[:turbo_stream])
      item.reload
      expect(item.description).to eq("Avena con plátano")
      expect(item.quantity).to eq("1 taza")
      expect(item.swap_options).to eq(%w[Yogurt] + ["Pan integral"])
    end
  end

  describe "DELETE /meal_items/:id" do
    let!(:item) { meal.meal_items.create!(description: "Yogurt", position: 0) }

    it "removes the item with a turbo-stream remove response" do
      expect {
        delete meal_item_path(item),
               headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change(MealItem, :count).by(-1)

      expect(response.body).to include("remove")
    end
  end
end
