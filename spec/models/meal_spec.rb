require "rails_helper"

RSpec.describe Meal, type: :model do
  it "is valid with factory" do
    expect(build(:meal)).to be_valid
  end

  it "has meal_type enum values" do
    expect(Meal.meal_types.keys).to match_array(%w[breakfast lunch dinner snack])
  end

  it "allows multiple snacks on the same day" do
    day = create(:plan_day)
    create(:meal, plan_day: day, meal_type: :snack, position: 0)
    second = build(:meal, plan_day: day, meal_type: :snack, position: 1)
    expect(second).to be_valid
  end

  it "orders by position via :ordered scope" do
    day = create(:plan_day)
    b = create(:meal, plan_day: day, meal_type: :breakfast, position: 2)
    a = create(:meal, plan_day: day, meal_type: :lunch, position: 1)
    expect(day.meals.ordered).to eq([a, b])
  end
end
