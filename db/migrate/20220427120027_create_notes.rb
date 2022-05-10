class CreateNotes < ActiveRecord::Migration[7.0]
  def change
    create_table :notes do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :scope, null: false, index: true
      t.string :record_id, null: false, index: true
      t.boolean :record_id_migrated, null: false, default: false
      t.text :value
      t.timestamps
    end
  end
end
