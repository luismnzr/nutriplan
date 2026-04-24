FactoryBot.define do
  factory :meal_log do
    meal
    status     { :eaten }
    logged_at  { Time.current }
  end
end
