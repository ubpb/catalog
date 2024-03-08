class CreateRegistrationRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :registration_requests do |t|
      t.string :token
      t.string :email
      t.string :user_group
      t.timestamps
    end

    add_index :registration_requests, :token, unique: true
  end
end
