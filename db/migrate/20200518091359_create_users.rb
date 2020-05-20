class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :first_name, null: false # for caching
      t.string :last_name, null: false  # for caching
      t.string :email, null: true       # for caching

      t.string :ils_primary_id, null: false, index: {unique: true}
    end
  end
end
