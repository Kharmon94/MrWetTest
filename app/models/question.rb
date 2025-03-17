class Question < ApplicationRecord
  belongs_to :test

  validates :content, :correct_answer, presence: true
end
