class AddCourseIdAndTestTypeToTests < ActiveRecord::Migration[8.0]
  def up
    # First, add the columns as nullable
    add_reference :tests, :course, null: true, foreign_key: true
    add_column :tests, :test_type, :string # 'long' or 'short'
    add_reference :tests, :lesson, null: true, foreign_key: true # Optional lesson association
    
    # Assign existing tests to the first course if any exist
    if Course.exists?
      first_course = Course.first
      Test.where(course_id: nil).update_all(course_id: first_course.id)
    end
    
    # Now make course_id not null
    change_column_null :tests, :course_id, false
    
    # Remove price column
    remove_column :tests, :price if column_exists?(:tests, :price)
  end
  
  def down
    add_column :tests, :price, :decimal, precision: 8, scale: 2, default: 0.0
    remove_reference :tests, :lesson
    remove_column :tests, :test_type
    remove_reference :tests, :course
  end
end
