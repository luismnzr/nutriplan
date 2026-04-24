class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :owned_plans,    class_name: "MealPlan", foreign_key: :owner_id,    dependent: :destroy, inverse_of: :owner
  has_many :assigned_plans, class_name: "MealPlan", foreign_key: :assignee_id, dependent: :restrict_with_error, inverse_of: :assignee
  has_many :daily_notes, dependent: :destroy
end
