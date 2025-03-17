class AddSubmittedAndScoreToAssessments < ActiveRecord::Migration[8.0]
  def change
    add_column :assessments, :submitted, :boolean
    # add_column :assessments, :score, :decimal
  end
end
