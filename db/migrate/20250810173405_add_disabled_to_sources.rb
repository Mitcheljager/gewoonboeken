class AddDisabledToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :disabled, :boolean, default: false
  end
end
