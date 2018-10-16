class CreateSalts < ActiveRecord::Migration[5.1]
  def change
    create_table :salts do |t|
      t.belongs_to :user, foreign_key: true
      t.string :salt_string

      t.timestamps
    end
  end
end
