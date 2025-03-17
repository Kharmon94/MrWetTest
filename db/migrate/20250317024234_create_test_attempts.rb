class CreateTestAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :test_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :test, null: false, foreign_key: true
      t.decimal :score
      t.boolean :submitted
      t.datetime :taken_at

      t.timestamps
    end
  end
end
