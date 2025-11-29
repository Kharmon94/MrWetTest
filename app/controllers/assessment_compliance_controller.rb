class AssessmentComplianceController < ApplicationController
  before_action :authenticate_user!
  before_action :set_test
  before_action :check_access

  def show_procedures
    # Display assessment procedures before starting
    @procedures_text = AssessmentComplianceService.assessment_procedures_text
    @instructions = AssessmentComplianceService.generate_assessment_instructions(@test, current_user)
    @compliance_errors = AssessmentComplianceService.validate_assessment_compliance(@test, current_user)
  end

  def show_honor_statement
    # Display honor statement before starting assessment
    @honor_statement_text = AssessmentComplianceService.honor_statement_text
    @test_attempt = current_user.test_attempts.build(test: @test)
  end

  def security_policies
    # Display internet security and privacy policies for electronic testing
    @security_policies_text = AssessmentComplianceService.internet_security_policies_text
  end
  def accept_honor_statement
    unless params[:honor_statement_accepted] == '1'
      flash[:alert] = "You must accept the honor statement to proceed with the assessment."
      render :show_honor_statement
      return
    end

    # Log the honor statement acceptance
    Rails.logger.info "Honor Statement Accepted - User: #{current_user.email}, Test: #{@test.title}, Time: #{Time.current}"
    
    # Store honor statement acceptance in session
    session["honor_statement_accepted_#{@test.id}"] = true
    
    # Check if user is enrolled in the course
    unless current_user.has_role?(:admin) || current_user.has_purchased?(@test.course)
      redirect_to course_path(@test.course), alert: "You must be enrolled in this course to take its tests." and return
    end
    
    # Check max attempts
    unless @test.can_user_retake?(current_user)
      redirect_to course_test_path(@test.course, @test), alert: "You have reached the maximum number of attempts for this test." and return
    end

    # Create test attempt directly
    @test_attempt = current_user.test_attempts.build(
      test: @test, 
      submitted: false,
      retake_number: 1,
      start_time: Time.current,
      honor_statement_accepted: true
    )
    
    if @test_attempt.save
      # Clear honor statement acceptance flag
      session.delete("honor_statement_accepted_#{@test.id}")
      redirect_to edit_tests_test_attempt_path(@test_attempt), 
                  notice: "Honor statement accepted. Assessment started."
    else
      Rails.logger.error "Failed to create test attempt: #{@test_attempt.errors.full_messages.join(', ')}"
      redirect_to new_tests_test_attempt_path(test_id: @test.id), 
                  alert: "Failed to start assessment: #{@test_attempt.errors.full_messages.join(', ')}"
    end
  end

  def abandon_assessment
    @test_attempt = current_user.test_attempts.find(params[:id])
    @test = @test_attempt.test
    
    if @test_attempt.update(end_time: Time.current)
      AssessmentComplianceService.log_assessment_event(:assessment_abandoned, @test_attempt, {
        reason: params[:reason],
        time_elapsed: @test_attempt.duration_minutes
      })
      
      flash[:notice] = "Assessment abandoned. You may retake it if attempts remain."
      redirect_to tests_test_attempt_path(@test_attempt)
    else
      flash[:alert] = "Error abandoning assessment."
      redirect_to tests_test_attempt_path(@test_attempt)
    end
  end

  private

  def set_test
    @test = Test.find(params[:id] || params[:test_id])
  end

  def check_access
    unless current_user.can_access?(@test.course)
      redirect_to course_path(@test.course), alert: "You do not have access to this assessment."
    end
  end

  def test_attempt_params
    params.require(:test_attempt).permit(:test_id)
  end
end
