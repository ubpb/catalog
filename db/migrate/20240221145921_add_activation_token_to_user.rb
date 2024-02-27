class AddActivationTokenToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :activation_token, :string, null: true
    add_column :users, :activation_token_created_at, :timestamp, null: true
    add_index :users, :activation_token, unique: true
  end
end
