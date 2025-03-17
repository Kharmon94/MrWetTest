class TestAttemptQuestion < ApplicationRecord
  belongs_to :test_attempt
  belongs_to :question

  validates :chosen_answer, presence: true, if: :submitted?
end
