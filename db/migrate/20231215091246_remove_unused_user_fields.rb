class RemoveUnusedUserFields < ActiveRecord::Migration[7.1]
  def up
    change_table :users, bulk: true do |t|
      t.remove :first_name if t.column_exists?(:first_name)
      t.remove :last_name if t.column_exists?(:last_name)
      t.remove :email if t.column_exists?(:email)
      t.remove :user_group_code if t.column_exists?(:user_group_code)
      t.remove :user_group_label if t.column_exists?(:user_group_label)
      t.remove :expiry_date if t.column_exists?(:expiry_date)
      t.remove :force_password_change if t.column_exists?(:force_password_change)
    end
  end
end
