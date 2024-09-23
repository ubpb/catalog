class CreateAdminGlobalMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :admin_global_messages do |t|
      t.boolean :active, null: false, default: false
      t.string :style, null: false, default: "info"
      t.text :message, null: true
      t.timestamps
    end
  end
end
