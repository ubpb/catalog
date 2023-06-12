class AddForcePasswordChangeToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :force_password_change, :boolean, null: false, default: false
  end
end
