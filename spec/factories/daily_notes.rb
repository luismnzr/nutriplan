FactoryBot.define do
  factory :daily_note do
    user
    plan_day
    overall_score { 4 }
    energy_level  { 4 }
    hunger_level  { 3 }
    mood          { "bien" }
    free_text     { "todo ok" }
  end
end
