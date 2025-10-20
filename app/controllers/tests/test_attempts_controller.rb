class Tests::TestAttemptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_test_attempt, only: [:show, :edit, :update, :abandon]
  before_action :secure_assessment_headers, only: [:edit, :update]

  # GET /tests/test_attempts
  def index
    @test_attempts = current_user.test_attempts.order(taken_at: :desc)
  end

  # GET /tests/test_attempts/new?test_id=:test_id
  def new
    @test = Test.find(params[:test_id])
    
    # Redirect to honor statement if required
    if @test.requires_honor_statement? && !session["honor_statement_accepted_#{@test.id}"]
      redirect_to honor_statement_test_path(@test) and return
    end
    
    # Display instructions for the test.
  end

  # POST /tests/test_attempts
  def create
    @test = Test.find(params[:test_id])
    
    # Check if user is enrolled in the course
    unless current_user.has_role?(:admin) || current_user.has_purchased?(@test.course)
      redirect_to course_path(@test.course), alert: "You must be enrolled in this course to take its tests." and return
    end
    
    # Check honor statement requirement
    if @test.requires_honor_statement? && !session["honor_statement_accepted_#{@test.id}"]
      flash[:alert] = "You must agree to the honor statement to proceed."
      redirect_to honor_statement_test_path(@test) and return
    end
    
    # Check max attempts
    unless @test.can_user_retake?(current_user)
      redirect_to course_test_path(@test.course, @test), alert: "You have reached the maximum number of attempts for this test." and return
    end

    @test_attempt = current_user.test_attempts.build(
      test: @test, 
      submitted: false,
      retake_number: 1,
      start_time: Time.current,
      honor_statement_accepted: @test.requires_honor_statement? ? true : false
    )
    
    unless @test_attempt.save
      Rails.logger.error "Failed to create test attempt: #{@test_attempt.errors.full_messages.join(', ')}"
      flash[:alert] = "Failed to create test attempt: #{@test_attempt.errors.full_messages.join(', ')}"
      redirect_to new_tests_test_attempt_path(test_id: params[:test_id]) and return
    end

    # Clear honor statement acceptance flag
    session.delete("honor_statement_accepted_#{@test.id}")

    redirect_to edit_tests_test_attempt_path(@test_attempt)
  end

  # GET /tests/test_attempts/:id
  def show
    # Display the test attempt results.
    # Questions are already loaded via set_test_attempt with includes
  end

  # GET /tests/test_attempts/:id/edit
  def edit
    if @test_attempt.submitted?
      redirect_to tests_test_attempt_path(@test_attempt), alert: "This test attempt has already been submitted."
      return
    end
    # Render form for answering questions.
  end

  # PATCH/PUT /tests/test_attempts/:id
  def update
    if @test_attempt.submitted?
      flash[:alert] = "This test attempt has already been submitted. Answers cannot be changed after submission."
      redirect_to tests_test_attempt_path(@test_attempt) and return
    end

    # Check if time has expired
    if @test_attempt.time_expired?
      flash[:alert] = "Time has expired. Your test has been automatically submitted."
      @test_attempt.submit!
      redirect_to tests_test_attempt_path(@test_attempt) and return
    end

    # Update answers (only if not submitted and time not expired)
    params[:test_attempt_questions]&.each do |taq_id, answer|
      taq = @test_attempt.test_attempt_questions.find(taq_id)
      # Prevent answer changes after submission (compliance requirement)
      unless taq.respond_to?(:locked) && taq.locked
        taq.update(chosen_answer: answer)
      end
    end

    if params[:Submit]
      # Final validation before submission
      unless @test_attempt.can_be_submitted?
        flash[:alert] = "Cannot submit test. Please ensure you have accepted the honor statement and time has not expired."
        redirect_to edit_tests_test_attempt_path(@test_attempt) and return
      end
      
      # Validate assessment integrity before submission
      unless validate_assessment_integrity(@test_attempt)
        Rails.logger.warn "Assessment integrity check failed for user #{current_user.id}, test attempt #{@test_attempt.id}"
      end
      
      @test_attempt.submit!
      
      flash[:notice] = "Test submitted successfully! Your score: #{@test_attempt.score}%"
      redirect_to tests_test_attempt_path(@test_attempt) and return
    end

    redirect_to edit_tests_test_attempt_path(@test_attempt)
  end

  def abandon
    if @test_attempt.update(end_time: Time.current)
      flash[:notice] = "Assessment abandoned. You may retake it if attempts remain."
      redirect_to tests_test_attempt_path(@test_attempt)
    else
      flash[:alert] = "Error abandoning assessment."
      redirect_to tests_test_attempt_path(@test_attempt)
    end
  end

  private

  def set_test_attempt
    if current_user.has_role?(:admin)
      @test_attempt = TestAttempt.includes(:test_attempt_questions => :question).find(params[:id])
    else
      @test_attempt = current_user.test_attempts.includes(:test_attempt_questions => :question).find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to tests_test_attempts_path, alert: "Test attempt not found."
  end
end
