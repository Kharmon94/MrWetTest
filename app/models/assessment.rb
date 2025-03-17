class Assessment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :assessment_questions, dependent: :destroy
  has_many :questions, through: :assessment_questions

  def calculate_score
    total = assessment_questions.count
    # Count correct answers. Assumes each question has a 'correct_answer' field.
    correct = assessment_questions.select { |aq| aq.chosen_answer == aq.question.correct_answer }.count
    (correct.to_f / total * 100).round(2)
  end
end
