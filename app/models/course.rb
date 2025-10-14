class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :assessments, dependent: :destroy
  # Remove or comment out any questions association:
  # has_many :questions, dependent: :destroy
  has_one_attached :thumbnail
  validates :title, :description, :price, presence: true
end
