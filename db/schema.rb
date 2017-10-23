# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171021005224) do

  create_table "indicators", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "result_id"
    t.string "code", limit: 15, null: false
    t.string "description", limit: 255, null: false
    t.index ["project_id"], name: "index_indicators_on_project_id"
    t.index ["result_id"], name: "index_indicators_on_result_id"
  end

  create_table "objectives", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "code", limit: 15, null: false
    t.string "description", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_objectives_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "results", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "objective_id"
    t.string "code", limit: 15, null: false
    t.string "description", limit: 255, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["objective_id"], name: "index_results_on_objective_id"
    t.index ["project_id"], name: "index_results_on_project_id"
  end

end
