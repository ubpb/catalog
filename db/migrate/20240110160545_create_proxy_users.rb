class CreateProxyUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :proxy_users do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :ils_primary_id, null: false
      t.string :label, null: false
      t.date :expiry_date
      t.timestamps
    end
  end
end
