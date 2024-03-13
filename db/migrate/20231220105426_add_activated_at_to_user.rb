class AddActivatedAtToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :activated_at, :timestamp, null: true
  end
end
