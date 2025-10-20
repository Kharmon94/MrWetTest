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
    
    redirect_to new_tests_test_attempt_path(test_id: @test.id), 
                notice: "Honor statement accepted. You can now start the assessment."
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
