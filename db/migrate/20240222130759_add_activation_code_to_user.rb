class AddActivationCodeToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :activation_code, :string, null: true
    add_index :users, :activation_code, unique: true
  end
end
