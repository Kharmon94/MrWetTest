class AddQuestionTypeToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_column :questions, :question_type, :string, default: 'short_answer'
    add_column :questions, :options, :text # JSON field for multiple choice options
    add_column :questions, :max_length, :integer, default: 500 # For text length limits
    
    add_index :questions, :question_type
  end
end
