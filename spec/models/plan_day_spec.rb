require "rails_helper"

RSpec.describe PlanDay, type: :model do
  it "is valid with factory" do
    expect(build(:plan_day)).to be_valid
  end

  it "requires date" do
    pd = build(:plan_day, date: nil)
    expect(pd).not_to be_valid
    expect(pd.errors[:date]).to be_present
  end

  it "enforces uniqueness of date per meal_plan" do
    plan = create(:meal_plan)
    create(:plan_day, meal_plan: plan, date: plan.start_date)
    dupe = build(:plan_day, meal_plan: plan, date: plan.start_date)
    expect(dupe).not_to be_valid
  end

  it "allows same date on a different plan" do
    date = Date.current
    create(:plan_day, meal_plan: create(:meal_plan), date: date)
    other = build(:plan_day, meal_plan: create(:meal_plan), date: date)
    expect(other).to be_valid
  end
end
