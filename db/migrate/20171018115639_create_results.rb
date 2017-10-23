class CreateResults < ActiveRecord::Migration[5.1]
  def change
    create_table :results do |t|
      t.references :project, foreign_key: true, null: false
      t.references :objective, foreign_key: true
      t.string :code, limit: 15, null: false
      t.string :description, limit: 255, null: false

      t.timestamps
    end
  end
end
