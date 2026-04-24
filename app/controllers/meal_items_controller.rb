class MealItemsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_meal, only: :create
  before_action :set_item, only: [:update, :destroy]
  before_action :ensure_owns_meal, only: :create
  before_action :ensure_owns_item, only: [:update, :destroy]

  # POST /meals/:meal_id/meal_items
  def create
    next_pos = (@meal.meal_items.maximum(:position) || -1) + 1
    @item = @meal.meal_items.build(
      new_item_params.reverse_merge(description: "Nuevo alimento", position: next_pos)
    )

    if @item.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            dom_id(@meal, :items),
            partial: "meal_items/meal_item",
            locals: { meal_item: @item }
          )
        end
        format.html { redirect_to edit_plan_path(@meal.plan_day.meal_plan) }
      end
    else
      head :unprocessable_entity
    end
  end

  # PATCH /meal_items/:id
  def update
    if @item.update(item_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            dom_id(@item),
            partial: "meal_items/meal_item",
            locals: { meal_item: @item }
          )
        end
        format.html { redirect_to edit_plan_path(@item.meal.plan_day.meal_plan) }
      end
    else
      head :unprocessable_entity
    end
  end

  # DELETE /meal_items/:id
  def destroy
    @item.destroy!
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@item)) }
      format.html { redirect_to edit_plan_path(@item.meal.plan_day.meal_plan) }
    end
  end

  private

  def set_meal
    @meal = Meal.find(params[:meal_id])
  end

  def set_item
    @item = MealItem.find(params[:id])
  end

  def ensure_owns_meal
    head :forbidden unless @meal.plan_day.meal_plan.owner_id == current_user.id
  end

  def ensure_owns_item
    head :forbidden unless @item.meal.plan_day.meal_plan.owner_id == current_user.id
  end

  def item_params
    permitted = params.require(:meal_item).permit(:description, :quantity, :swap_options, :position)
    if permitted[:swap_options].is_a?(String)
      permitted[:swap_options] = permitted[:swap_options].split(/\r?\n/)
    end
    permitted
  end

  def new_item_params
    return {} unless params[:meal_item]
    params.require(:meal_item).permit(:description, :quantity, :position)
  end
end
