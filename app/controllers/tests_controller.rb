class TestsController < ApplicationController
  # This controller handles standalone test routes
  # The actual test functionality is handled by Courses::TestsController
  # This is just a placeholder for routing purposes
  
  def show
    # This should not be called directly
    redirect_to root_path, alert: "Please access tests through courses."
  end
  
  # Delegate to AssessmentComplianceController for honor statement routes
  def honor_statement
    redirect_to action: 'show_honor_statement', controller: 'assessment_compliance'
  end
  
  def accept_honor
    redirect_to action: 'accept_honor_statement', controller: 'assessment_compliance'
  end
end

