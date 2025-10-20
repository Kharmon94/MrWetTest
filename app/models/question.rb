class Question < ApplicationRecord
  belongs_to :test
  has_many :test_attempt_questions, dependent: :destroy

  validates :content, :correct_answer, presence: true
  validates :question_type, inclusion: { in: %w[multiple_choice short_answer long_form true_false] }
  validates :max_length, numericality: { greater_than: 0 }, allow_nil: true

  # Serialize options for multiple choice questions
  serialize :options, coder: JSON

  # Question type constants
  QUESTION_TYPES = {
    'multiple_choice' => 'Multiple Choice',
    'short_answer' => 'Short Answer',
    'long_form' => 'Long Form',
    'true_false' => 'True/False'
  }.freeze
  
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
  
  # Question type helper methods
  def multiple_choice?
    question_type == 'multiple_choice'
  end

  def short_answer?
    question_type == 'short_answer'
  end

  def long_form?
    question_type == 'long_form'
  end

  def true_false?
    question_type == 'true_false'
  end

  def question_type_display
    QUESTION_TYPES[question_type] || 'Unknown'
  end

  def multiple_choice_options
    return [] unless multiple_choice? && options.present?
    options.is_a?(Array) ? options : JSON.parse(options)
  end

  def text_input_placeholder
    case question_type
    when 'short_answer'
      "Enter a brief answer (max #{max_length || 100} characters)..."
    when 'long_form'
      "Enter your detailed response (max #{max_length || 1000} characters)..."
    else
      "Enter your answer here..."
    end
  end

  def text_area_rows
    case question_type
    when 'short_answer'
      2
    when 'long_form'
      6
    else
      3
    end
  end

  def validate_answer_format(answer)
    return true if answer.blank?
    
    case question_type
    when 'multiple_choice', 'true_false'
      # For multiple choice, answer should be one of the options
      if multiple_choice?
        multiple_choice_options.include?(answer)
      else
        ['True', 'False', 'true', 'false'].include?(answer)
      end
    when 'short_answer', 'long_form'
      # For text answers, check length
      return false if max_length.present? && answer.length > max_length
      true
    else
      true
    end
  end

  # Override the old question_type method to use the database field
  def question_type_from_content
    # Legacy method for backward compatibility
    if content.match?(/\b(true|false)\b/i)
      'true_false'
    elsif content.match?(/\b(which|what|how|when|where|why)\b/i)
      'multiple_choice'
    else
      'short_answer'
    end
  end
end
