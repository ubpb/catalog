class AddUserGroupToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_group_code, :string
    add_column :users, :user_group_label, :string
  end
end
