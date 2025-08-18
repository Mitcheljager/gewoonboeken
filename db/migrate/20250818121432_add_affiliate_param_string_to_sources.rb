class AddAffiliateParamStringToSources < ActiveRecord::Migration[8.0]
  def change
    add_column :sources, :affiliate_param_string, :string
  end
end
