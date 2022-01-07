class AddPasswordResetToken < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :password_reset_token, :string, index: {unique: true}, null: true
    add_column :users, :password_reset_token_created_at, :timestamp, null: true
  end
end
