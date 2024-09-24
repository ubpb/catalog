class CreateProxyUsers < ActiveRecord::Migration[7.1]

  def change
    create_table :proxy_users do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :ils_primary_id, null: false
      t.string :name, null: false
      t.string :note, null: true
      t.date :expired_at
      t.timestamps
    end

    add_index :proxy_users, [:user_id, :ils_primary_id], unique: true
  end

end
