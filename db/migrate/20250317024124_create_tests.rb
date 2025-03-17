class CreateTests < ActiveRecord::Migration[8.0]
  def change
    create_table :tests do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.text :instructions

      t.timestamps
    end
  end
end
