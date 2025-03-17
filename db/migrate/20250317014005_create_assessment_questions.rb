class CreateAssessmentQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :assessment_questions do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.string :chosen_answer

      t.timestamps
    end
  end
end
