class CreateRememberTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :remember_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token

      t.timestamps
    end
  end
end
