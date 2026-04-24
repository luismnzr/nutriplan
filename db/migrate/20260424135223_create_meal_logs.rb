class CreateMealLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :meal_logs do |t|
      t.references :meal, null: false, foreign_key: true, index: { unique: true }
      t.integer :status, null: false, default: 0
      t.text :actual_description
      t.datetime :logged_at

      t.timestamps
    end
  end
end
