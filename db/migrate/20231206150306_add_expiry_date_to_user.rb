class AddExpiryDateToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :expiry_date, :date, null: true
  end
end
