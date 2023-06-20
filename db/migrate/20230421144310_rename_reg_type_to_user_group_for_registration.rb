class RenameRegTypeToUserGroupForRegistration < ActiveRecord::Migration[7.0]
  def up
    return unless column_exists?(:registrations, :reg_type)

    rename_column :registrations, :reg_type, :user_group
  end
end
