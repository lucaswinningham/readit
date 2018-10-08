class CreatePosts < ActiveRecord::Migration[5.1]
  def change
    create_table :posts do |t|
      t.belongs_to :user, foreign_key: true
      t.belongs_to :sub, foreign_key: true
      t.text :title
      t.string :url
      t.text :body
      t.boolean :active

      t.timestamps
    end
  end
end
