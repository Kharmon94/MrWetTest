class TestAttemptQuestion < ApplicationRecord
  belongs_to :test_attempt
  belongs_to :question
end
