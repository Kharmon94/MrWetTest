class AssessmentQuestion < ApplicationRecord
  belongs_to :assessment
  belongs_to :question

  # Optionally, validate presence of chosen_answer after submission.
end
