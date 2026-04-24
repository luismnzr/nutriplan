class CreatePlanDays < ActiveRecord::Migration[7.2]
  def change
    create_table :plan_days do |t|
      t.references :meal_plan, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :plan_days, [:meal_plan_id, :date], unique: true
  end
end
