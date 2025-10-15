class AddPolymorphicFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_reference :payments, :payable, polymorphic: true, null: false
  end
end
