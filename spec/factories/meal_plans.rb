FactoryBot.define do
  factory :meal_plan do
    owner { association :user }
    assignee { owner }
    sequence(:name) { |n| "Plan #{n}" }
    start_date { Date.current }
    end_date   { Date.current + 6.days }

    trait :with_days do
      after(:create) do |plan|
        (plan.start_date..plan.end_date).each do |d|
          create(:plan_day, meal_plan: plan, date: d)
        end
      end
    end
  end
end
