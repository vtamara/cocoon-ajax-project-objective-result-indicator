class CreateObjectives < ActiveRecord::Migration[5.1]
  def change
    create_table :objectives do |t|
      t.references :project, foreign_key: true
      t.string :code, limit: 15
      t.string :description, limit: 255

      t.timestamps
    end
  end
end
