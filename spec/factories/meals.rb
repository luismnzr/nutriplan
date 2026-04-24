FactoryBot.define do
  factory :meal do
    plan_day
    meal_type { :breakfast }
    time      { "08:00" }
    sequence(:position) { |n| n }
  end
end
