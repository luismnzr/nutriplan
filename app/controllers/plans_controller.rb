class PlansController < ApplicationController
  before_action :set_plan, only: [:show, :edit, :update, :destroy, :shopping_list]

  def index
    @plans = current_user.owned_plans.order(start_date: :desc)
  end

  def show
  end

  def new
    monday = Date.current.beginning_of_week(:monday)
    @plan = current_user.owned_plans.build(
      name:       I18n.l(monday, format: "Semana del %-d de %B"),
      start_date: monday,
      end_date:   monday + 6.days
    )
  end

  def create
    @plan = current_user.owned_plans.build(plan_params)
    @plan.assignee = current_user

    if @plan.save
      generate_skeleton(@plan)
      redirect_to edit_plan_path(@plan), notice: "Plan creado"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @plan.update(plan_params)
      redirect_to edit_plan_path(@plan), notice: "Plan actualizado"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plan.destroy!
    redirect_to plans_path, notice: "Plan eliminado"
  end

  def shopping_list
    @rows = @plan.shopping_list
  end

  private

  def set_plan
    @plan = current_user.owned_plans.find(params[:id])
  end

  def plan_params
    params.require(:meal_plan).permit(:name, :start_date, :end_date, :notes)
  end

  def generate_skeleton(plan)
    default_times = {
      "breakfast" => "08:00",
      "lunch"     => "14:00",
      "dinner"    => "20:00",
      "snack"     => "17:00"
    }

    (plan.start_date..plan.end_date).each do |date|
      day = plan.plan_days.create!(date: date)
      Meal.meal_types.keys.each_with_index do |type, idx|
        day.meals.create!(meal_type: type, time: default_times[type], position: idx)
      end
    end
  end
end
