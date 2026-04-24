require "rails_helper"

RSpec.describe MealLog, type: :model do
  it "is valid with factory" do
    expect(build(:meal_log)).to be_valid
  end

  it "exposes the four statuses" do
    expect(MealLog.statuses.keys).to match_array(%w[planned eaten skipped modified])
  end

  describe "#fulfilled?" do
    it "is true for eaten and modified, false otherwise" do
      expect(build(:meal_log, status: :eaten).fulfilled?).to be true
      expect(build(:meal_log, status: :modified).fulfilled?).to be true
      expect(build(:meal_log, status: :planned).fulfilled?).to be false
      expect(build(:meal_log, status: :skipped).fulfilled?).to be false
    end
  end

  it "only allows one log per meal" do
    meal = create(:meal)
    create(:meal_log, meal: meal)
    expect { create(:meal_log, meal: meal) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
