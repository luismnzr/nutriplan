require "rails_helper"

RSpec.describe "DailyNotes", type: :request do
  let(:user) { create(:user) }
  let(:plan) { create(:meal_plan, owner: user, assignee: user) }
  let(:day)  { plan.plan_days.create!(date: Date.current) }

  before { sign_in user }

  describe "POST /plan_days/:plan_day_id/daily_note" do
    let(:params) do
      {
        daily_note: {
          overall_score: 4,
          energy_level:  5,
          hunger_level:  3,
          mood:          "bien",
          free_text:     "Día tranquilo"
        }
      }
    end

    it "creates a daily note for the plan_day and current user" do
      expect {
        post plan_day_daily_note_path(day),
             params: params,
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.to change { user.daily_notes.count }.by(1)

      note = user.daily_notes.find_by!(plan_day_id: day.id)
      expect(note.overall_score).to eq(4)
      expect(note.mood).to eq("bien")
      expect(response.body).to include("replace")
    end

    it "updates the existing note instead of creating a duplicate" do
      user.daily_notes.create!(plan_day: day, overall_score: 2)

      expect {
        post plan_day_daily_note_path(day),
             params: params,
             headers: { "Accept" => "text/vnd.turbo-stream.html" }
      }.not_to change { DailyNote.count }

      note = user.daily_notes.find_by!(plan_day_id: day.id)
      expect(note.overall_score).to eq(4)
      expect(note.mood).to eq("bien")
    end

    it "is forbidden when the plan belongs to another user" do
      other = create(:user)
      other_plan = create(:meal_plan, owner: other, assignee: other)
      other_day  = other_plan.plan_days.create!(date: Date.current)

      post plan_day_daily_note_path(other_day),
           params: params,
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
