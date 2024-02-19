class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.string :content, null: false
      t.integer :type, null: false
      t.references :user, null: false, foreign_key: true
      t.references :utility, null: false, foreign_key: true

      t.timestamps
    end
  end
end
