class Course < ApplicationRecord
    has_many :lessons, dependent: :destroy
    has_many :questions, dependent: :destroy
    has_many :assessments, dependent: :destroy
  
    validates :title, presence: true
    validates :description, presence: true
  end
  