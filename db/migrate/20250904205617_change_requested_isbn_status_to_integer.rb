class ChangeRequestedISBNStatusToInteger < ActiveRecord::Migration[8.0]
  def change
    change_column :requested_isbns, :status, :integer, default: 0, null: false
  end
end
