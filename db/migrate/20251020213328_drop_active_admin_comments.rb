class DropActiveAdminComments < ActiveRecord::Migration[8.0]
  def change
    drop_table :active_admin_comments
  end
end
