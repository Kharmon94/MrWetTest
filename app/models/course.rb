class Course < ApplicationRecord
  has_many :lessons, dependent: :destroy
  has_many :tests, dependent: :destroy
  has_many :assessments, dependent: :destroy
  has_many :payments, as: :payable, dependent: :destroy
  # Remove or comment out any questions association:
  # has_many :questions, dependent: :destroy
  has_one_attached :thumbnail
  
  validates :title, :description, :price, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :time_managed, inclusion: { in: [true, false] }, allow_nil: true
  validates :chapter_assessments_required, inclusion: { in: [true, false] }, allow_nil: true
  
  # Payment-related methods
  def free?
    price.blank? || price == 0
  end
  
  def paid?
    !free?
  end
  
  def formatted_price
    return "Free" if free?
    "USD $#{sprintf('%.2f', price)}"
  end
  
  def stripe_price_id
    # This would be set when creating a Stripe product/price
    # For now, we'll generate it dynamically
    "price_#{id}_#{created_at.to_i}"
  end

  # Chapter Assessment Methods
  
  def time_managed?
    time_managed
  end
  
  def requires_chapter_assessments?
    chapter_assessments_required || time_managed?
  end
  
  
  def lesson_tests(lesson)
    tests.where(lesson: lesson)
  end
  
  def chapter_tests
    tests.where(assessment_type: 'chapter')
  end
  
  def final_assessment
    tests.find_by(assessment_type: 'final')
  end
  
  def user_has_completed_all_chapters?(user)
    return true unless requires_chapter_assessments?
    
    chapter_tests.all? do |test|
      user.test_attempts.where(test: test, submitted: true).exists?
    end
  end
  
  def user_can_take_final_assessment?(user)
    return true unless requires_chapter_assessments?
    user_has_completed_all_chapters?(user)
  end
  
  def user_progress(user)
    return { progress: 0, last_lesson: nil, completed_lessons: 0 } unless user
    
    # For now, we'll implement a simple progress tracking
    # In a real app, you might track lesson views or completions
    total_lessons = lessons.count
    return { progress: 0, last_lesson: nil, completed_lessons: 0 } if total_lessons == 0
    
    # Simple implementation: assume user has started if they have any test attempts
    has_started = user.test_attempts.joins(:test).where(tests: { course: self }).exists?
    
    if has_started
      # Find the last lesson they might have accessed
      last_lesson = lessons.order(:position).first
      completed_lessons = 1 # Assume they've completed at least the first lesson
      progress = (completed_lessons.to_f / total_lessons * 100).round
    else
      last_lesson = nil
      completed_lessons = 0
      progress = 0
    end
    
    {
      progress: progress,
      last_lesson: last_lesson,
      completed_lessons: completed_lessons,
      total_lessons: total_lessons,
      has_started: has_started
    }
  end
  
  def chapter_completion_status(user)
    return {} unless requires_chapter_assessments?
    
    status = {}
    lessons.each_with_index do |lesson, index|
      chapter_number = index + 1
      lesson_test = tests.find_by(lesson: lesson, assessment_type: 'chapter')
      
      if lesson_test
        attempts = user.test_attempts.where(test: lesson_test)
        latest_attempt = attempts.order(created_at: :desc).first
        
        status[chapter_number] = {
          completed: latest_attempt&.submitted? || false,
          passed: latest_attempt&.passed? || false,
          score: latest_attempt&.score || 0,
          attempts: attempts.count,
          lesson_id: lesson.id,
          test_id: lesson_test.id
        }
      else
        status[chapter_number] = {
          completed: false,
          passed: false,
          score: 0,
          attempts: 0,
          lesson_id: lesson.id,
          test_id: nil
        }
      end
    end
    
    status
  end
  
  def user_chapter_progress(user)
    return { completed: 0, total: 0, progress_percentage: 0 } unless requires_chapter_assessments?
    
    total_chapters = lessons.count
    completed_chapters = 0
    
    lessons.each do |lesson|
      lesson_test = tests.find_by(lesson: lesson, assessment_type: 'chapter')
      next unless lesson_test
      
      if user_has_passed_chapter_assessment?(user, lesson_test)
        completed_chapters += 1
      end
    end
    
    progress_percentage = total_chapters > 0 ? (completed_chapters.to_f / total_chapters * 100).round : 0
    
    {
      completed: completed_chapters,
      total: total_chapters,
      progress_percentage: progress_percentage
    }
  end
  
  def next_required_chapter_assessment(user)
    return nil unless requires_chapter_assessments?
    
    lessons.order(:position).each do |lesson|
      lesson_test = tests.find_by(lesson: lesson, assessment_type: 'chapter')
      next unless lesson_test
      
      unless user_has_passed_chapter_assessment?(user, lesson_test)
        return lesson_test
      end
    end
    
    nil
  end
  
  def user_needs_chapter_review?(user, lesson)
    return false unless requires_chapter_assessments?
    
    lesson_test = tests.find_by(lesson: lesson, assessment_type: 'chapter')
    return false unless lesson_test
    
    # Check if user has failed the chapter assessment and needs to review
    latest_attempt = user.test_attempts.where(test: lesson_test).order(created_at: :desc).first
    return false unless latest_attempt
    
    latest_attempt.submitted? && !latest_attempt.passed?
  end
  
  def user_can_retake_chapter_assessment?(user, lesson)
    return false unless requires_chapter_assessments?
    
    lesson_test = tests.find_by(lesson: lesson, assessment_type: 'chapter')
    return false unless lesson_test
    
    # User can retake if they've completed the chapter review after failing
    # For now, we'll allow retakes if they haven't passed yet
    !user_has_passed_chapter_assessment?(user, lesson_test)
  end

  def user_completion_status(user)
    attempts = user.test_attempts.where(test: tests)
    
    if attempts.empty?
      :not_started
    elsif attempts.any?(&:submitted?)
      :completed
    else
      :in_progress
    end
  end

  def user_completion_percentage(user)
    attempts = user.test_attempts.where(test: tests)
    return 0 if attempts.empty?
    
    submitted_attempts = attempts.where(submitted: true)
    return 0 if tests.empty?
    
    (submitted_attempts.count.to_f / tests.count * 100).round
  end

  def user_has_passed?(user)
    attempts = user.test_attempts.where(test: tests)
    return false if attempts.empty?
    
    attempts.any? do |attempt|
      attempt.submitted? && attempt.score && attempt.score >= (attempt.test.passing_score || 70)
    end
  end
end
