class CreateNonces < ActiveRecord::Migration[5.1]
  def change
    create_table :nonces do |t|
      t.belongs_to :user, foreign_key: true
      t.string :nonce_string
      t.datetime :expiration_at

      t.timestamps
    end
  end
end
