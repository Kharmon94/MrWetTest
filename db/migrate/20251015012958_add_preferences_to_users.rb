class AddPreferencesToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :theme_preference, :string
    add_column :users, :email_notifications, :boolean
    add_column :users, :push_notifications, :boolean
    add_column :users, :timezone, :string
    add_column :users, :language, :string
  end
end
