require "rails_helper"

RSpec.describe MealPlan, "#shopping_list", type: :model do
  let(:user) { create(:user) }
  let(:plan) { create(:meal_plan, owner: user, assignee: user) }
  let(:day)  { plan.plan_days.create!(date: plan.start_date) }
  let(:meal) { day.meals.create!(meal_type: :breakfast, position: 0) }

  it "groups items by normalized description" do
    meal.meal_items.create!(description: "Avena", quantity: "1 taza", position: 0)
    meal.meal_items.create!(description: "  AVENA  ", quantity: "2 taza", position: 1)
    rows = plan.shopping_list
    expect(rows.map { |r| r[:description] }).to contain_exactly("Avena")
    expect(rows.first[:quantity]).to eq("3 taza")
  end

  it "sorts alphabetically by description" do
    meal.meal_items.create!(description: "Zanahoria", quantity: "1", position: 0)
    meal.meal_items.create!(description: "Avena",     quantity: "1", position: 1)
    expect(plan.shopping_list.map { |r| r[:description] }).to eq(%w[Avena Zanahoria])
  end

  it "reflects existing checks" do
    meal.meal_items.create!(description: "Avena", quantity: "1 taza", position: 0)
    plan.shopping_list_checks.create!(item_key: "avena")
    expect(plan.shopping_list.first).to include(checked: true, key: "avena")
  end

  it "combines heterogenous quantities with ' + '" do
    meal.meal_items.create!(description: "Sal", quantity: "al gusto", position: 0)
    meal.meal_items.create!(description: "Sal", quantity: "1 pizca", position: 1)
    expect(plan.shopping_list.first[:quantity]).to eq("1 pizca + al gusto")
  end
end
