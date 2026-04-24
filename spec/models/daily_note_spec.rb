require "rails_helper"

RSpec.describe DailyNote, type: :model do
  it "is valid with factory" do
    expect(build(:daily_note)).to be_valid
  end

  it "rejects scores out of 1..5" do
    note = build(:daily_note, overall_score: 6)
    expect(note).not_to be_valid
    expect(note.errors[:overall_score]).to be_present
  end

  it "allows nil sub-ratings" do
    note = build(:daily_note, energy_level: nil, hunger_level: nil, overall_score: nil)
    expect(note).to be_valid
  end

  it "enforces one note per (user, plan_day)" do
    user = create(:user)
    day  = create(:plan_day)
    create(:daily_note, user: user, plan_day: day)
    dupe = build(:daily_note, user: user, plan_day: day)
    expect(dupe).not_to be_valid
  end
end
