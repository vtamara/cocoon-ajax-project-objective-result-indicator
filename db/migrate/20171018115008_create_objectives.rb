class CreateObjectives < ActiveRecord::Migration[5.1]
  def change
    create_table :objectives do |t|
      t.references :project, foreign_key: true, null: false
      t.string :code, limit: 15, null: false
      t.string :description, limit: 255, null: false

      t.timestamps
    end
  end
end
