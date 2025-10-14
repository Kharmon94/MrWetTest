class AssessmentQuestion < ApplicationRecord
  belongs_to :assessment
  belongs_to :question

  validates :chosen_answer, presence: true, if: :assessment_submitted?

  def correct?
    chosen_answer == question.correct_answer
  end

  private

  def assessment_submitted?
    assessment&.submitted?
  end
end
