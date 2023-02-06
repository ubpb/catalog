class CreateFixedHistoryLoans < ActiveRecord::Migration[7.0]
  def change
    create_table :fixed_history_loans do |t|
      t.string :ils_primary_id
      t.date   :return_date
      t.string :barcode
      t.string :alma_id
      t.string :title
      t.string :author
      t.timestamps
    end
  end
end
