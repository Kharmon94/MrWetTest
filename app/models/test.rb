class Test < ApplicationRecord
    has_many :questions, dependent: :destroy
    has_many :test_attempts, dependent: :destroy
  
    validates :title, :description, :instructions, presence: true
    validates :price, presence: true, numericality: true
  end
  