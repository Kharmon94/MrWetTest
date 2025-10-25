class RemoveTestTypeFromTests < ActiveRecord::Migration[8.0]
  def change
    remove_column :tests, :test_type, :string
  end
end
