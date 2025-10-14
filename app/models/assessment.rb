class Assessment < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_many :assessment_questions, dependent: :destroy

  validates :user_id, :course_id, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def calculate_score
    total = assessment_questions.count
    return 0 if total == 0
    
    correct = assessment_questions.select do |aq|
      aq.chosen_answer == aq.question.correct_answer
    end.count
    
    (correct.to_f / total * 100).round(2)
  end

  def completed?
    submitted == true
  end

  def in_progress?
    submitted == false
  end
end
