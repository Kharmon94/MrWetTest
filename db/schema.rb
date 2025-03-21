# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_17_024422) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "author_type"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource"
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "assessment_questions", force: :cascade do |t|
    t.integer "assessment_id", null: false
    t.integer "question_id", null: false
    t.string "chosen_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assessment_id"], name: "index_assessment_questions_on_assessment_id"
    t.index ["question_id"], name: "index_assessment_questions_on_question_id"
  end

  create_table "assessments", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "course_id", null: false
    t.decimal "score"
    t.datetime "taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "submitted"
    t.index ["course_id"], name: "index_assessments_on_course_id"
    t.index ["user_id"], name: "index_assessments_on_user_id"
  end

  create_table "courses", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "lessons", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.integer "position"
    t.integer "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_lessons_on_course_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "content"
    t.string "correct_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "test_id", null: false
    t.index ["test_id"], name: "index_questions_on_test_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "test_attempt_questions", force: :cascade do |t|
    t.integer "test_attempt_id", null: false
    t.integer "question_id", null: false
    t.string "chosen_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_test_attempt_questions_on_question_id"
    t.index ["test_attempt_id"], name: "index_test_attempt_questions_on_test_attempt_id"
  end

  create_table "test_attempts", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "test_id", null: false
    t.decimal "score"
    t.boolean "submitted"
    t.datetime "taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_id"], name: "index_test_attempts_on_test_id"
    t.index ["user_id"], name: "index_test_attempts_on_user_id"
  end

  create_table "tests", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.decimal "price"
    t.text "instructions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "assessment_questions", "assessments"
  add_foreign_key "assessment_questions", "questions"
  add_foreign_key "assessments", "courses"
  add_foreign_key "assessments", "users"
  add_foreign_key "lessons", "courses"
  add_foreign_key "questions", "tests"
  add_foreign_key "test_attempt_questions", "questions"
  add_foreign_key "test_attempt_questions", "test_attempts"
  add_foreign_key "test_attempts", "tests"
  add_foreign_key "test_attempts", "users"
end
