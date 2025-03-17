class Lesson < ApplicationRecord
  belongs_to :course

  validates :title, presence: true
  validates :content, presence: true
  validates :position, numericality: { only_integer: true }, allow_nil: true
end
