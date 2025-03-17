class Question < ApplicationRecord
  belongs_to :course

  # You might want to add fields for answer options if needed
  validates :content, presence: true
  validates :correct_answer, presence: true
end
