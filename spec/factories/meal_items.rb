FactoryBot.define do
  factory :meal_item do
    meal
    description { Faker::Food.dish }
    quantity    { "1 porción" }
    swap_options { [] }
    sequence(:position) { |n| n }
  end
end
