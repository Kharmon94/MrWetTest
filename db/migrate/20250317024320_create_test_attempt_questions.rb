class CreateTestAttemptQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :test_attempt_questions do |t|
      t.references :test_attempt, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :chosen_answer

      t.timestamps
    end
  end
end
