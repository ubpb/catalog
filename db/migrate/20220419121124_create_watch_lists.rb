class CreateWatchLists < ActiveRecord::Migration[7.0]
  def change
    create_table :watch_lists do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    create_table :watch_list_entries do |t|
      t.belongs_to :watch_list, foreign_key: true, null: false
      t.string :scope, null: false, index: true
      t.string :record_id, null: false, index: true
      t.boolean :record_id_migrated, null: false, default: false
      t.timestamps
    end
  end
end
