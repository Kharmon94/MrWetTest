class AddComplianceFieldsToTestAttempts < ActiveRecord::Migration[8.0]
  def change
    add_column :test_attempts, :honor_statement_accepted, :boolean
    add_column :test_attempts, :start_time, :datetime
    add_column :test_attempts, :end_time, :datetime
    add_column :test_attempts, :questions_used, :text
    add_column :test_attempts, :retake_number, :integer
  end
end
