class DailyNotesController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_plan_day
  before_action :ensure_owns_plan

  # POST /plan_days/:plan_day_id/daily_note
  def create
    note = current_user.daily_notes.find_or_initialize_by(plan_day_id: @plan_day.id)
    note.assign_attributes(note_params)
    note.save!

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@plan_day, :note),
          partial: "today/daily_note_form",
          locals: { plan_day: @plan_day, daily_note: note, saved_at: Time.current }
        )
      end
      format.html { redirect_to today_path }
    end
  end

  private

  def set_plan_day
    @plan_day = PlanDay.includes(:meal_plan).find(params[:plan_day_id])
  end

  def ensure_owns_plan
    head :forbidden unless @plan_day.meal_plan.owner_id == current_user.id
  end

  def note_params
    params.require(:daily_note).permit(
      :overall_score, :energy_level, :hunger_level, :mood, :free_text
    )
  end
end
