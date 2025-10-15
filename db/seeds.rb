# db/seeds.rb - Sea Pass Pro Academic Integrity Compliance Seeds

puts "🌊 Starting Sea Pass Pro seed process..."
puts "➡️ Clearing old data..."

# Clear existing data using destroy_all to handle foreign key constraints properly
puts "   Clearing test attempt questions..."
TestAttemptQuestion.destroy_all
puts "   Clearing test attempts..."
TestAttempt.destroy_all
puts "   Clearing payments..."
Payment.destroy_all
puts "   Clearing questions..."
Question.destroy_all
puts "   Clearing tests..."
Test.destroy_all
puts "   Clearing lessons..."
Lesson.destroy_all
puts "   Clearing courses..."
Course.destroy_all
puts "   Clearing users..."
User.destroy_all
puts "   Clearing roles..."
Role.destroy_all

puts "➡️ Creating roles..."
admin_role = Role.create!(name: "admin")
student_role = Role.create!(name: "student")
instructor_role = Role.create!(name: "instructor")

puts "➡️ Seeding users..."
# Admin user
admin = User.create!(
  email: "admin@seapasspro.com", 
  password: "password123",
  theme_preference: "dark",
  email_notifications: true,
  push_notifications: true,
  language: "en"
)
admin.add_role(:admin)

# Instructor user
instructor = User.create!(
  email: "instructor@seapasspro.com", 
  password: "password123",
  theme_preference: "light",
  email_notifications: true,
  push_notifications: false,
  language: "en"
)
instructor.add_role(:instructor)

# Sample students
students = []
3.times do |i|
  student = User.create!(
    email: "student#{i+1}@seapasspro.com", 
    password: "password123",
    theme_preference: ["light", "dark", "auto"][i],
    email_notifications: [true, false, true][i],
    push_notifications: [false, true, true][i],
    language: ["en", "en", "ja"][i]
  )
  student.add_role(:student)
  students << student
end

puts "➡️ Seeding courses with compliance features..."

# Maritime Safety Course (Time-managed with chapter assessments)
maritime_course = Course.create!(
  title: "Maritime Safety Fundamentals", 
  description: "Comprehensive maritime safety training covering international regulations, emergency procedures, and safety protocols for commercial vessels.",
  price: 299.99,
  time_managed: true,
  chapter_assessments_required: true
)

# Create lessons for maritime course
maritime_lessons = [
  { title: "International Maritime Law", content: "Understanding SOLAS, MARPOL, and STCW conventions that govern maritime safety worldwide.", position: 1 },
  { title: "Emergency Response Procedures", content: "Fire fighting, abandon ship procedures, and emergency communication protocols.", position: 2 },
  { title: "Personal Safety Equipment", content: "Life jackets, immersion suits, emergency position-indicating radio beacons (EPIRBs), and survival techniques.", position: 3 },
  { title: "Navigation Safety", content: "Collision avoidance, radar usage, and bridge resource management for safe navigation.", position: 4 },
  { title: "Cargo Safety", content: "Dangerous goods handling, cargo securing, and stability calculations for safe cargo operations.", position: 5 }
]

maritime_lessons.each do |lesson_data|
  Lesson.create!(
    course: maritime_course,
    title: lesson_data[:title],
    content: lesson_data[:content],
    position: lesson_data[:position]
  )
end

# Navigation Course (Regular course)
navigation_course = Course.create!(
  title: "Advanced Navigation Systems",
  description: "Modern electronic navigation systems, GPS, radar, and electronic chart display systems.",
  price: 199.99,
  time_managed: false,
  chapter_assessments_required: false
)

navigation_lessons = [
  { title: "GPS and Satellite Navigation", content: "Global Positioning System fundamentals and satellite navigation principles.", position: 1 },
  { title: "Electronic Chart Systems", content: "ECDIS operation, chart updates, and electronic navigation procedures.", position: 2 },
  { title: "Radar Operation", content: "Radar principles, interpretation, and collision avoidance techniques.", position: 3 }
]

navigation_lessons.each do |lesson_data|
  Lesson.create!(
    course: navigation_course,
    title: lesson_data[:title],
    content: lesson_data[:content],
    position: lesson_data[:position]
  )
end

# Free Course
free_course = Course.create!(
  title: "Maritime Industry Overview",
  description: "Introduction to the maritime industry, career paths, and basic terminology.",
  price: 0.00,
  time_managed: false,
  chapter_assessments_required: false
)

puts "➡️ Seeding tests with compliance features..."

# Chapter Assessments for Maritime Course
chapter_tests = []
5.times do |i|
  test = Test.create!(
    title: "Chapter #{i+1} Assessment - #{maritime_lessons[i][:title]}",
    description: "Assessment for #{maritime_lessons[i][:title]} covering key learning objectives and safety procedures.",
    price: 0.00,
    instructions: "Complete all questions within the time limit. This assessment is required before proceeding to the next chapter.",
    assessment_type: "chapter",
    time_limit: 30,
    honor_statement_required: false,
    max_attempts: 3,
    passing_score: 70.0,
    question_pool_size: 10
  )
  chapter_tests << test
  
  # Create 40 questions per chapter (4x requirement for 10 questions)
  40.times do |j|
    question_number = j + 1
    content = case i
    when 0 # Maritime Law
      [
        "Which convention establishes minimum standards for training, certification, and watchkeeping?",
        "What does SOLAS stand for in maritime safety?",
        "Which regulation covers the prevention of pollution from ships?",
        "What is the minimum age requirement for seafarers under STCW?",
        "Which organization sets international maritime safety standards?"
      ][j % 5] + " (Question #{question_number})"
    when 1 # Emergency Response
      [
        "What is the correct procedure for a fire emergency on board?",
        "How should abandon ship signals be given?",
        "What is the muster station procedure?",
        "How should emergency communications be handled?",
        "What are the requirements for emergency lighting?"
      ][j % 5] + " (Question #{question_number})"
    when 2 # Safety Equipment
      [
        "What is the proper way to don a life jacket?",
        "When should immersion suits be worn?",
        "How often should EPIRBs be tested?",
        "What is the purpose of SART devices?",
        "How should safety equipment be maintained?"
      ][j % 5] + " (Question #{question_number})"
    when 3 # Navigation Safety
      [
        "What is the rule of the road for collision avoidance?",
        "How should radar be used for navigation?",
        "What is bridge resource management?",
        "How should navigation lights be displayed?",
        "What are the requirements for lookout duties?"
      ][j % 5] + " (Question #{question_number})"
    when 4 # Cargo Safety
      [
        "How should dangerous goods be stowed?",
        "What are the requirements for cargo securing?",
        "How is vessel stability calculated?",
        "What are the IMDG code requirements?",
        "How should cargo operations be supervised?"
      ][j % 5] + " (Question #{question_number})"
    end
    
    correct_answer = case i
    when 0
      ["STCW Convention", "Safety of Life at Sea", "MARPOL", "16 years", "IMO"][j % 5]
    when 1
      ["Sound alarm and fight fire", "Continuous blast of whistle", "Proceed to assigned station", "Use emergency frequencies", "Must function for 3 hours"][j % 5]
    when 2
      ["Put arms through armholes and fasten", "In cold water conditions", "Monthly", "Search and rescue transponder", "Regular inspection and testing"][j % 5]
    when 3
      ["Keep to starboard in narrow channels", "Monitor continuously", "Team coordination", "As specified in COLREGS", "Continuous and effective"][j % 5]
    when 4
      ["According to segregation table", "Securely lashed", "Using stability calculations", "Follow IMDG guidelines", "By qualified officer"][j % 5]
    end
    
    Question.create!(
      test: test,
      content: content,
      correct_answer: correct_answer
    )
  end
end

# Final Assessment for Maritime Course
maritime_final = Test.create!(
  title: "Maritime Safety Fundamentals - Final Assessment",
  description: "Comprehensive final assessment covering all maritime safety topics. Must be passed to complete the course.",
  price: 0.00,
  instructions: "This is a final assessment. You must complete all chapter assessments before taking this test. Honor statement required.",
  assessment_type: "final",
  time_limit: 120,
  honor_statement_required: true,
  max_attempts: 2,
  passing_score: 80.0,
  question_pool_size: 50
)

# Create 200 questions for final (4x requirement for 50 questions)
200.times do |i|
  question_number = i + 1
  topics = ["Maritime Law", "Emergency Response", "Safety Equipment", "Navigation Safety", "Cargo Safety"]
  topic = topics[i % 5]
  
  content = case i % 5
  when 0 # Maritime Law
    [
      "What is the primary purpose of the STCW Convention?",
      "Which SOLAS chapter covers fire safety?",
      "What does MARPOL Annex I regulate?",
      "Who is responsible for ship security under ISPS Code?",
      "What are the watchkeeping requirements under STCW?"
    ][i % 5] + " (Final Question #{question_number})"
  when 1 # Emergency Response
    [
      "What is the first action in a fire emergency?",
      "How should emergency signals be given?",
      "What is the muster list procedure?",
      "How should emergency communications be established?",
      "What are the requirements for emergency power?"
    ][i % 5] + " (Final Question #{question_number})"
  when 2 # Safety Equipment
    [
      "What is the minimum number of life jackets required?",
      "When must immersion suits be provided?",
      "How should EPIRBs be activated?",
      "What is the range of SART devices?",
      "How often should lifeboats be tested?"
    ][i % 5] + " (Final Question #{question_number})"
  when 3 # Navigation Safety
    [
      "What is the stand-on vessel's obligation?",
      "How should radar be used in restricted visibility?",
      "What is the purpose of bridge resource management?",
      "When should navigation lights be displayed?",
      "What are the lookout requirements?"
    ][i % 5] + " (Final Question #{question_number})"
  when 4 # Cargo Safety
    [
      "How should dangerous goods be segregated?",
      "What is the minimum securing strength?",
      "How is GM calculated for stability?",
      "What are the IMDG classification requirements?",
      "Who supervises cargo operations?"
    ][i % 5] + " (Final Question #{question_number})"
  end
  
  correct_answer = case i % 5
  when 0
    ["Training standards", "Chapter II-2", "Oil pollution", "Master", "4 hours on, 8 hours off"][i % 5]
  when 1
    ["Sound alarm", "Continuous blast", "Check muster list", "Use emergency frequencies", "3 hours minimum"][i % 5]
  when 2
    ["One per person", "Cold water areas", "Remove safety pin", "5 nautical miles", "Monthly"][i % 5]
  when 3
    ["Maintain course and speed", "Monitor continuously", "Team coordination", "From sunset to sunrise", "Continuous and effective"][i % 5]
  when 4
    ["By segregation table", "50% of cargo weight", "KM minus KG", "9 classes", "Qualified officer"][i % 5]
  end
  
  Question.create!(
    test: maritime_final,
    content: content,
    correct_answer: correct_answer
  )
end

# Navigation Systems Test
navigation_test = Test.create!(
  title: "Electronic Navigation Systems Certification",
  description: "Certification test for electronic navigation systems including GPS, radar, and ECDIS.",
  price: 99.99,
  instructions: "This certification test requires honor statement acceptance. Complete all questions within the time limit.",
  assessment_type: "final",
  time_limit: 90,
  honor_statement_required: true,
  max_attempts: 3,
  passing_score: 75.0,
  question_pool_size: 25
)

# Create 100 questions for navigation test (4x requirement)
100.times do |i|
  question_number = i + 1
  content = case i % 4
  when 0
    [
      "What is the accuracy of GPS under normal conditions?",
      "How many satellites are needed for 3D positioning?",
      "What is the purpose of WAAS?",
      "How often should GPS position be updated?",
      "What causes GPS signal degradation?"
    ][i % 5] + " (Question #{question_number})"
  when 1
    [
      "What does ECDIS stand for?",
      "How often should electronic charts be updated?",
      "What is the purpose of ENC?",
      "How should ECDIS alarms be handled?",
      "What is the backup requirement for ECDIS?"
    ][i % 5] + " (Question #{question_number})"
  when 2
    [
      "What is the radar range resolution?",
      "How should radar be tuned for best performance?",
      "What causes radar interference?",
      "How should radar echoes be interpreted?",
      "What is the minimum range of radar?"
    ][i % 5] + " (Question #{question_number})"
  when 3
    [
      "What is AIS used for?",
      "How often does AIS transmit position?",
      "What information does AIS provide?",
      "How should AIS alarms be handled?",
      "What is the AIS range limitation?"
    ][i % 5] + " (Question #{question_number})"
  end
  
  correct_answer = case i % 4
  when 0
    ["3-5 meters", "4 satellites", "Improve accuracy", "Every second", "Atmospheric conditions"][i % 5]
  when 1
    ["Electronic Chart Display", "Weekly", "Chart data", "Immediately", "Paper charts"][i % 5]
  when 2
    ["0.1 nautical miles", "Auto tune", "Weather", "Size and shape", "0.5 nautical miles"][i % 5]
  when 3
    ["Vessel identification", "Every 3 seconds", "Position and course", "Immediately", "40 nautical miles"][i % 5]
  end
  
  Question.create!(
    test: navigation_test,
    content: content,
    correct_answer: correct_answer
  )
end

# Practice Test
practice_test = Test.create!(
  title: "Maritime Safety Practice Test",
  description: "Practice test for maritime safety fundamentals. No honor statement required.",
  price: 0.00,
  instructions: "This is a practice test. Use it to prepare for the final assessment.",
  assessment_type: "practice",
  time_limit: 60,
  honor_statement_required: false,
  max_attempts: nil,
  passing_score: nil,
  question_pool_size: 20
)

# Create 80 practice questions (4x requirement)
80.times do |i|
  question_number = i + 1
  content = "Practice question #{question_number}: What is the most important aspect of maritime safety? (A) Equipment (B) Training (C) Regulations (D) All of the above"
  correct_answer = "All of the above"
  
  Question.create!(
    test: practice_test,
    content: content,
    correct_answer: correct_answer
  )
end

puts "➡️ Seeding test attempts and payments..."

# Create some sample test attempts with compliance features
students.each_with_index do |student, student_index|
  # Student 1: Has completed some chapter assessments
  if student_index == 0
    # Chapter 1 - Passed
    attempt1 = TestAttempt.create!(
      user: student,
      test: chapter_tests[0],
      submitted: true,
      taken_at: 3.days.ago,
      score: 85.0,
      honor_statement_accepted: false,
      start_time: 3.days.ago,
      end_time: 3.days.ago + 25.minutes,
      retake_number: 1
    )
    
    # Create some questions for this attempt
    chapter_tests[0].questions.sample(10).each do |question|
      attempt1.test_attempt_questions.create!(
        question: question,
        chosen_answer: question.correct_answer
      )
    end
    
  elsif student_index == 1
    # Student 2: Completed all chapters and final
    chapter_tests.each_with_index do |test, index|
      attempt = TestAttempt.create!(
        user: student,
        test: test,
        submitted: true,
        taken_at: (5 - index).days.ago,
        score: 80.0 + (index * 2),
        honor_statement_accepted: false,
        start_time: (5 - index).days.ago,
        end_time: (5 - index).days.ago + 25.minutes,
        retake_number: 1
      )
      
      test.questions.sample(10).each do |question|
        attempt.test_attempt_questions.create!(
          question: question,
          chosen_answer: question.correct_answer
        )
      end
    end
    
    # Final assessment - Passed
    final_attempt = TestAttempt.create!(
      user: student,
      test: maritime_final,
      submitted: true,
      taken_at: 1.day.ago,
      score: 82.0,
      honor_statement_accepted: true,
      start_time: 1.day.ago,
      end_time: 1.day.ago + 115.minutes,
      retake_number: 1
    )
    
    maritime_final.questions.sample(50).each do |question|
      final_attempt.test_attempt_questions.create!(
        question: question,
        chosen_answer: question.correct_answer
      )
    end
    
  else
    # Student 3: Has some practice attempts
    practice_attempt = TestAttempt.create!(
      user: student,
      test: practice_test,
      submitted: true,
      taken_at: 2.days.ago,
      score: 70.0,
      honor_statement_accepted: false,
      start_time: 2.days.ago,
      end_time: 2.days.ago + 55.minutes,
      retake_number: 1
    )
    
    practice_test.questions.sample(20).each do |question|
      practice_attempt.test_attempt_questions.create!(
        question: question,
        chosen_answer: question.correct_answer
      )
    end
  end
end

# Create some payments
Payment.create!(
  user: students[1],
  payable: navigation_test,
  amount: 99.99,
  currency: "usd",
  status: "succeeded",
  payment_method: "card",
  stripe_payment_intent_id: "pi_test_123456789"
)

Payment.create!(
  user: students[2],
  payable: navigation_course,
  amount: 199.99,
  currency: "usd",
  status: "succeeded",
  payment_method: "card",
  stripe_payment_intent_id: "pi_test_987654321"
)

puts "✅ Sea Pass Pro seed complete!"
puts "📊 Summary:"
puts "   👥 Users: #{User.count} (#{User.joins(:roles).where(roles: {name: 'admin'}).count} admin, #{User.joins(:roles).where(roles: {name: 'student'}).count} students)"
puts "   📚 Courses: #{Course.count} (#{Course.where(time_managed: true).count} time-managed)"
puts "   📖 Lessons: #{Lesson.count}"
puts "   📝 Tests: #{Test.count} (#{Test.where(assessment_type: 'final').count} final, #{Test.where(assessment_type: 'chapter').count} chapter)"
puts "   ❓ Questions: #{Question.count}"
puts "   🎯 Attempts: #{TestAttempt.count}"
puts "   💳 Payments: #{Payment.count}"
puts ""
puts "🔑 Login credentials:"
puts "   Admin: admin@seapasspro.com / password123"
puts "   Instructor: instructor@seapasspro.com / password123"
puts "   Students: student1@seapasspro.com / password123 (has partial progress)"
puts "           student2@seapasspro.com / password123 (completed course)"
puts "           student3@seapasspro.com / password123 (practice only)"
puts ""
puts "🌊 Welcome to Sea Pass Pro - Your Maritime Education Platform!"