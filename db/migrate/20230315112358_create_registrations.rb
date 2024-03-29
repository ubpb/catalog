class CreateRegistrations < ActiveRecord::Migration[7.0]
  def change
    create_table :registrations do |t|
      t.string :user_group
      t.string :academic_title
      t.string :gender
      t.string :firstname
      t.string :lastname
      t.date   :birthdate
      t.string :email
      t.string :street_address
      t.string :zip_code
      t.string :city
      t.string :street_address2
      t.string :zip_code2
      t.string :city2
      t.boolean :terms_of_use, null: false, default: false
      t.boolean :created_in_alma, null: false, default: false
      t.string  :alma_primary_id
      t.timestamps
    end
  end
end
