class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :content
      t.string :correct_answer
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
