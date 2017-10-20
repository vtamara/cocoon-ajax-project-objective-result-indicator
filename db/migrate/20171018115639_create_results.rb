class CreateResults < ActiveRecord::Migration[5.1]
  def change
    create_table :results do |t|
      t.references :objective, foreign_key: true
      t.string :code, limit: 15
      t.string :description, limit: 255

      t.timestamps
    end
  end
end
