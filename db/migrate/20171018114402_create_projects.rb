class CreateProjects < ActiveRecord::Migration[5.1]
  def change
    create_table :projects do |t|
      t.string :name, limit: 255, null: false

      t.timestamps
    end
  end
end
