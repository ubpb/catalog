class RecreateProxyUsers < ActiveRecord::Migration[7.2]

  def up
    drop_table :proxy_users

    create_table :proxy_users do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :proxy_user, null: false, foreign_key: {to_table: :users}
      t.string :note, null: true
      t.date :expired_at
      t.timestamps
    end

    add_index :proxy_users, [:user_id, :proxy_user_id], unique: true
  end

end
