class RemovedFixedHistoryLoans < ActiveRecord::Migration[7.0]
  def up
    drop_table :fixed_history_loans
  end
end
