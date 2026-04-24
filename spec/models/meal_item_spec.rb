require "rails_helper"

RSpec.describe MealItem, type: :model do
  it "is valid with factory" do
    expect(build(:meal_item)).to be_valid
  end

  it "requires description" do
    item = build(:meal_item, description: nil)
    expect(item).not_to be_valid
  end

  it "defaults swap_options to an empty array when persisted" do
    item = create(:meal_item)
    expect(item.swap_options).to eq([])
  end

  it "normalizes swap_options on save: trims whitespace and drops blanks" do
    item = create(:meal_item, swap_options: ["  Yogurt ", "", "Omelette", "   "])
    expect(item.swap_options).to eq(%w[Yogurt Omelette])
  end

  # String coercion is handled in the controller (MealItemsController#item_params).
  # PG array columns cast a String to [] on assignment, so the model receives
  # a pre-split Array already.
end
