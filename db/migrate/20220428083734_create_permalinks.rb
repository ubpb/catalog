class CreatePermalinks < ActiveRecord::Migration[7.0]
  def change
    create_table :permalinks do |t|
      t.string :key, null: false, index: {unique: true}
      t.string :scope, null: false, index: true
      t.text :search_request, null: false
      t.datetime :last_resolved_at
      t.timestamps
    end
  end
end
