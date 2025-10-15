class AddComplianceFieldsToTests < ActiveRecord::Migration[8.0]
  def change
    add_column :tests, :assessment_type, :string
    add_column :tests, :time_limit, :integer
    add_column :tests, :honor_statement_required, :boolean
    add_column :tests, :max_attempts, :integer
    add_column :tests, :passing_score, :decimal
    add_column :tests, :question_pool_size, :integer
  end
end
