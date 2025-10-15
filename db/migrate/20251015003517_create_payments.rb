class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.decimal :amount
      t.string :currency
      t.string :status
      t.string :payment_method
      t.text :metadata

      t.timestamps
    end
  end
end
