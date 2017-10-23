class CreateIndicators < ActiveRecord::Migration[5.1]
  def change
    create_table :indicators do |t|
      t.references :project, foreign_key: true, null: false
      t.references :result, foreign_key: true
      t.string :code, limit: 15, null: false
      t.string :description, limit: 255, null: false
    end
  end
end
