class Question < ApplicationRecord
  belongs_to :test
  has_many :test_attempt_questions, dependent: :destroy

  validates :content, :correct_answer, presence: true
  validates :question_type, inclusion: { in: ['multiple_choice'] }
  validates :options, presence: true, length: { minimum: 2 }
  validate :correct_answer_must_be_in_options

  # Serialize options for multiple choice questions
  serialize :options, coder: JSON

  before_validation :set_question_type

  # Question type constants
  QUESTION_TYPES = {
    'multiple_choice' => 'Multiple Choice'
  }.freeze
  
  # Question type helper methods
  def multiple_choice?
    question_type == 'multiple_choice'
  end

  def multiple_choice_options
    return [] unless multiple_choice? && options.present?
    options.is_a?(Array) ? options : JSON.parse(options)
  end

  def validate_answer_format(answer)
    return true if answer.blank?
    
    # For multiple choice, answer should be one of the options
    multiple_choice_options.include?(answer)
  end
  
  # Enhanced feedback methods for compliance
  def provide_feedback(chosen_answer)
    {
      correct: chosen_answer == correct_answer,
      correct_answer: correct_answer,
      chosen_answer: chosen_answer,
      explanation: explanation_text(chosen_answer),
      learning_objective: learning_objective_text,
      detailed_feedback: detailed_feedback_text(chosen_answer),
      improvement_suggestions: improvement_suggestions(chosen_answer)
    }
  end
  
  def explanation_text(chosen_answer)
    if chosen_answer == correct_answer
      "Correct! #{correct_explanation.presence || 'Well done.'}"
    else
      "Incorrect. #{incorrect_explanation.presence || 'Please review the material and try again.'}"
    end
  end
  
  def correct_explanation
    # Return explanation for correct answers - can be enhanced with database field
    nil
  end
  
  def incorrect_explanation
    # Return explanation for incorrect answers - can be enhanced with database field
    nil
  end
  
  def learning_objective_text
    learning_objective.presence || "Review the course material related to this topic."
  end
  
  def learning_objective
    # Return learning objective for the question - can be enhanced with database field
    nil
  end
  
  def detailed_feedback_text(chosen_answer)
    if chosen_answer == correct_answer
      "Excellent work! You demonstrated understanding of this concept. #{correct_explanation.presence || 'Keep up the good work!'}"
    else
      "This answer needs improvement. The correct answer is '#{correct_answer}'. #{incorrect_explanation.presence || 'Please review the course material to better understand this topic.'}"
    end
  end
  
  def improvement_suggestions(chosen_answer)
    if chosen_answer == correct_answer
      ["Continue practicing similar questions", "Review related topics to reinforce learning"]
    else
      ["Review the course material for this topic", "Practice similar questions", "Consider seeking clarification from instructor"]
    end
  end
  
  def difficulty_level
    # This could be enhanced with a difficulty field in the future
    case content.length
    when 0..100 then 'Easy'
    when 101..200 then 'Medium'
    else 'Hard'
    end
  end

  private

  def set_question_type
    self.question_type = 'multiple_choice'
  end

  def correct_answer_must_be_in_options
    return unless options.present? && correct_answer.present?
    
    unless multiple_choice_options.include?(correct_answer)
      errors.add(:correct_answer, 'must be one of the provided options')
    end
  end
end
