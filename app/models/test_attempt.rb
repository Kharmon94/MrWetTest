class TestAttempt < ApplicationRecord
  belongs_to :user
  belongs_to :test
  has_many :test_attempt_questions, dependent: :destroy

  def calculate_score
    total = test_attempt_questions.count
    correct = test_attempt_questions.select do |taq|
      taq.chosen_answer == taq.question.correct_answer
    end.count
    (correct.to_f / total * 100).round(2)
  end
end
