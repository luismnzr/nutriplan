require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with factory" do
    expect(build(:user)).to be_valid
  end

  it "has owned_plans and assigned_plans associations" do
    user = create(:user)
    plan = create(:meal_plan, owner: user, assignee: user)
    expect(user.owned_plans).to include(plan)
    expect(user.assigned_plans).to include(plan)
  end

  it "destroys owned plans when the user is destroyed" do
    user = create(:user)
    create(:meal_plan, owner: user, assignee: user)
    expect { user.destroy }.to change(MealPlan, :count).by(-1)
  end
end
