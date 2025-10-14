class TestAttemptQuestion < ApplicationRecord
  belongs_to :test_attempt
  belongs_to :question

  validates :chosen_answer, presence: true, if: :test_attempt_submitted?

  def correct?
    chosen_answer == question.correct_answer
  end

  private

  def test_attempt_submitted?
    test_attempt&.submitted?
  end
end
