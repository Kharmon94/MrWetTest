class DropActiveAdminComments < ActiveRecord::Migration[8.0]
  def up
    drop_table :active_admin_comments if table_exists?(:active_admin_comments)
  end

  def down
    create_table :active_admin_comments do |t|
      t.string :namespace
      t.text :body
      t.string :resource_type
      t.integer :resource_id
      t.string :author_type
      t.integer :author_id
      t.timestamps
    end

    add_index :active_admin_comments, [:author_type, :author_id], name: 'index_active_admin_comments_on_author'
    add_index :active_admin_comments, [:namespace], name: 'index_active_admin_comments_on_namespace'
    add_index :active_admin_comments, [:resource_type, :resource_id], name: 'index_active_admin_comments_on_resource'
  end
end