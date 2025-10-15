class Question < ApplicationRecord
  belongs_to :test
  has_many :test_attempt_questions, dependent: :destroy

  validates :content, :correct_answer, presence: true
  
  # Enhanced feedback methods for compliance
  def provide_feedback(chosen_answer)
    {
      correct: chosen_answer == correct_answer,
      correct_answer: correct_answer,
      explanation: explanation_text(chosen_answer),
      learning_objective: learning_objective_text
    }
  end
  
  def explanation_text(chosen_answer)
    if chosen_answer == correct_answer
      "Correct! #{correct_explanation.presence || 'Well done.'}"
    else
      "Incorrect. #{incorrect_explanation.presence || 'Please review the material and try again.'}"
    end
  end
  
  def learning_objective_text
    learning_objective.presence || "Review the course material related to this topic."
  end
  
  def difficulty_level
    # This could be enhanced with a difficulty field in the future
    case content.length
    when 0..100 then 'Easy'
    when 101..200 then 'Medium'
    else 'Hard'
    end
  end
  
  def question_type
    # Determine question type based on content analysis
    if content.match?(/\b(true|false)\b/i)
      'True/False'
    elsif content.match?(/\b(which|what|how|when|where|why)\b/i)
      'Multiple Choice'
    else
      'Multiple Choice'
    end
  end
end
