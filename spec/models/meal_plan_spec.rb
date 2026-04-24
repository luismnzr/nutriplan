require "rails_helper"

RSpec.describe MealPlan, type: :model do
  subject { build(:meal_plan) }

  it "is valid with defaults" do
    expect(subject).to be_valid
  end

  it "requires name, start_date and end_date" do
    plan = described_class.new
    expect(plan).not_to be_valid
    expect(plan.errors.attribute_names).to include(:name, :start_date, :end_date, :owner, :assignee)
  end

  it "rejects end_date before start_date" do
    plan = build(:meal_plan, start_date: Date.current, end_date: Date.current - 1)
    expect(plan).not_to be_valid
    expect(plan.errors[:end_date]).to be_present
  end

  it "accepts end_date equal to start_date" do
    plan = build(:meal_plan, start_date: Date.current, end_date: Date.current)
    expect(plan).to be_valid
  end

  describe "#personal?" do
    it "is true when owner and assignee are the same user" do
      expect(build(:meal_plan).personal?).to be true
    end

    it "is false when owner and assignee differ" do
      plan = build(:meal_plan, assignee: build(:user))
      expect(plan.personal?).to be false
    end
  end

  describe ".active_on" do
    it "returns plans whose range covers the given date" do
      active   = create(:meal_plan, start_date: Date.current - 2, end_date: Date.current + 2)
      _future  = create(:meal_plan, start_date: Date.current + 10, end_date: Date.current + 16)
      expect(described_class.active_on(Date.current)).to contain_exactly(active)
    end
  end
end
