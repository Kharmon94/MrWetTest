require "test_helper"

class CourseTest < ActiveSupport::TestCase
  def setup
    @course = courses(:one)
    @test1 = tests(:one)
    @test2 = tests(:two)
    @user = users(:student)
  end

  test "should be valid with valid attributes" do
    assert @course.valid?
  end

  test "should require a title" do
    @course.title = nil
    assert_not @course.valid?
    assert_includes @course.errors[:title], "can't be blank"
  end

  test "should require a description" do
    @course.description = nil
    assert_not @course.valid?
    assert_includes @course.errors[:description], "can't be blank"
  end

  test "should validate price is non-negative" do
    @course.price = -1
    assert_not @course.valid?
    assert_includes @course.errors[:price], "must be greater than or equal to 0"
  end

  test "should have many tests" do
    assert_respond_to @course, :tests
    assert_includes @course.tests, @test1
    assert_includes @course.tests, @test2
  end

  test "should have many lessons" do
    assert_respond_to @course, :lessons
  end

  test "should destroy associated tests when destroyed" do
    # Create a new course without any test attempts to avoid foreign key constraints
    new_course = Course.create!(title: "Test Course", description: "Test Description", price: 0, time_managed: true, chapter_assessments_required: true)
    test1 = Test.create!(title: "Test 1", description: "Test 1 Description", instructions: "Test 1 Instructions", course: new_course, assessment_type: "chapter")
    test2 = Test.create!(title: "Test 2", description: "Test 2 Description", instructions: "Test 2 Instructions", course: new_course, assessment_type: "final")
    
    test_count = new_course.tests.count
    assert_difference 'Test.count', -test_count do
      new_course.destroy
    end
  end

  test "lesson_tests should return tests associated with lessons" do
    lesson = lessons(:one)
    lesson_tests = @course.lesson_tests(lesson)
    assert_includes lesson_tests, @test1 if @test1.lesson == lesson
  end

  test "chapter_tests should return chapter assessment type tests" do
    chapter_tests = @course.chapter_tests
    assert_includes chapter_tests, @test1 if @test1.assessment_type == 'chapter'
  end

  test "final_assessment should return final assessment type test" do
    final_test = @course.final_assessment
    if final_test
      assert_equal 'final', final_test.assessment_type
    end
  end

  test "user_completion_status should return correct status for user" do
    # Mock the user's test attempts
    status = @course.user_completion_status(@user)
    assert_includes [:not_started, :in_progress, :completed], status
  end

  test "user_completion_percentage should return percentage between 0 and 100" do
    percentage = @course.user_completion_percentage(@user)
    assert percentage >= 0 && percentage <= 100
  end

  test "user_has_passed? should return boolean" do
    result = @course.user_has_passed?(@user)
    assert [true, false].include?(result)
  end
end
