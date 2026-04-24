class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index

  def index
    return unless user_signed_in?
    if current_user.owned_plans.active_on(Date.current).exists?
      redirect_to today_path
    else
      redirect_to plans_path
    end
  end
end
