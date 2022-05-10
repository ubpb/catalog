class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :ils_primary_id, null: false, index: {unique: true}
      t.string :api_key, null: true, index: {unique: true}

      t.string :first_name, null: false # for caching
      t.string :last_name, null: false  # for caching
      t.string :email, null: true       # for caching

      t.string :password_reset_token, null: true, index: {unique: true}
      t.timestamp :password_reset_token_created_at, null: true

      t.timestamps
    end
  end
end
