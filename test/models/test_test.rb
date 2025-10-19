require "test_helper"

class TestTest < ActiveSupport::TestCase
  def setup
    @course = courses(:one)
    @lesson = lessons(:one)
    @test = Test.new(
      title: "Test Title",
      description: "Test Description",
      instructions: "Test Instructions",
      assessment_type: "chapter",
      time_limit: 60,
      passing_score: 75,
      max_attempts: 3,
      honor_statement_required: true,
      course: @course,
      lesson: @lesson
    )
  end

  test "should be valid with valid attributes" do
    assert @test.valid?
  end

  test "should require a title" do
    @test.title = nil
    assert_not @test.valid?
    assert_includes @test.errors[:title], "can't be blank"
  end

  test "should require a description" do
    @test.description = nil
    assert_not @test.valid?
    assert_includes @test.errors[:description], "can't be blank"
  end

  test "should require instructions" do
    @test.instructions = nil
    assert_not @test.valid?
    assert_includes @test.errors[:instructions], "can't be blank"
  end

  test "should require a course" do
    @test.course = nil
    assert_not @test.valid?
    assert_includes @test.errors[:course], "must exist"
  end

  test "should allow lesson to be optional" do
    @test.lesson = nil
    assert @test.valid?
  end

  test "should validate assessment_type inclusion" do
    @test.assessment_type = "invalid"
    assert_not @test.valid?
    assert_includes @test.errors[:assessment_type], "is not included in the list"
  end

  test "should accept valid assessment_types" do
    valid_types = %w[chapter final practice]
    valid_types.each do |type|
      @test.assessment_type = type
      assert @test.valid?, "#{type} should be valid"
    end
  end

  test "should validate time_limit is positive" do
    @test.time_limit = -1
    assert_not @test.valid?
    assert_includes @test.errors[:time_limit], "must be greater than 0"
  end

  test "should validate passing_score is between 0 and 100" do
    @test.passing_score = -1
    assert_not @test.valid?
    assert_includes @test.errors[:passing_score], "must be greater than or equal to 0"

    @test.passing_score = 101
    assert_not @test.valid?
    assert_includes @test.errors[:passing_score], "must be less than or equal to 100"
  end

  test "should validate max_attempts is positive" do
    @test.max_attempts = -1
    assert_not @test.valid?
    assert_includes @test.errors[:max_attempts], "must be greater than 0"
  end

  test "should validate question_pool_size is positive" do
    @test.question_pool_size = -1
    assert_not @test.valid?
    assert_includes @test.errors[:question_pool_size], "must be greater than 0"
  end

  test "should belong to course" do
    assert_equal @course, @test.course
  end

  test "should belong to lesson" do
    assert_equal @lesson, @test.lesson
  end

  test "requires_honor_statement? should return correct value" do
    @test.honor_statement_required = true
    assert @test.requires_honor_statement?
    
    @test.honor_statement_required = false
    assert_not @test.requires_honor_statement?
  end

  test "can_user_retake? should return true when user has attempts left" do
    user = users(:student)
    @test.max_attempts = 3
    # User has no attempts yet, so should be able to retake
    assert @test.can_user_retake?(user)
  end

  test "can_user_retake? should return false when user has reached max attempts" do
    user = users(:student)
    @test.max_attempts = 1
    # Create a test attempt for this user and test
    TestAttempt.create!(user: user, test: @test, score: 80, submitted: true, 
                       honor_statement_accepted: true, retake_number: 1,
                       start_time: Time.current, end_time: Time.current)
    
    # User has reached max attempts
    assert_not @test.can_user_retake?(user)
  end
end
