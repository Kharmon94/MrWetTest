class ChangeQuestionReferenceFromCourseToTest < ActiveRecord::Migration[8.0]
  def up
    # Remove the course reference
    remove_reference :questions, :course, index: true, foreign_key: true

    # Add the test reference allowing NULL temporarily
    add_reference :questions, :test, foreign_key: true

    # Create or find a dummy Test record for existing questions.
    dummy_test = Test.find_or_create_by!(
      title: "Migrated Test",
      description: "Dummy test created during migration",
      price: 0,
      instructions: "N/A"
    )

    # Update all existing questions to have the dummy test_id
    Question.where(test_id: nil).update_all(test_id: dummy_test.id)

    # Change the column to NOT NULL now that every question has a test_id
    change_column_null :questions, :test_id, false
  end

  def down
    # Inverse migration: remove test reference and add course reference back.
    remove_reference :questions, :test, index: true, foreign_key: true
    add_reference :questions, :course, null: false, foreign_key: true
  end
end
