class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  # Remove or comment out any questions association:
  # has_many :questions, dependent: :destroy

  validates :title, :description, :price, presence: true
end
