FactoryBot.define do
  factory :plan_day do
    meal_plan
    date { meal_plan&.start_date || Date.current }
  end
end
