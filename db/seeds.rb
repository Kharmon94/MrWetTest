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

puts "➡️ Seeding tests with compliance features and multiple question types..."

# Chapter Assessments for Maritime Course
chapter_tests = []
5.times do |i|
  test = Test.create!(
    course: maritime_course,
    lesson: maritime_course.lessons.find_by(title: maritime_lessons[i][:title]),
    title: "Chapter #{i+1} Assessment - #{maritime_lessons[i][:title]}",
    description: "Assessment for #{maritime_lessons[i][:title]} covering key learning objectives and safety procedures.",
    instructions: "Complete all questions within the time limit. This assessment is required before proceeding to the next chapter.",
    assessment_type: "chapter",
    time_limit: 30,
    honor_statement_required: false,
    max_attempts: 3,
    passing_score: 70.0,
    question_pool_size: 10
  )
  chapter_tests << test
  
  # Create 40 questions per chapter (4x requirement for 10 questions) with different question types
  40.times do |j|
    question_number = j + 1
    
    # Determine question type based on position (mix of types)
    question_type = case j % 4
    when 0 then "multiple_choice"
    when 1 then "short_answer"
    when 2 then "true_false"
    when 3 then "long_form"
    end
    
    content = case i
    when 0 # Maritime Law
      case question_type
      when "multiple_choice"
        "Which convention establishes minimum standards for training, certification, and watchkeeping? (Question #{question_number})"
      when "short_answer"
        "What does SOLAS stand for? (Question #{question_number})"
      when "true_false"
        "STCW Convention applies to all seafarers. (Question #{question_number})"
      when "long_form"
        "Explain the key provisions of the STCW Convention and how they ensure maritime safety. (Question #{question_number})"
      end
    when 1 # Emergency Response
      case question_type
      when "multiple_choice"
        "What is the correct procedure for a fire emergency on board? (Question #{question_number})"
      when "short_answer"
        "How should abandon ship signals be given? (Question #{question_number})"
      when "true_false"
        "Emergency lighting must function for at least 3 hours. (Question #{question_number})"
      when "long_form"
        "Describe the complete fire emergency response procedure including alarm systems, crew duties, and safety measures. (Question #{question_number})"
      end
    when 2 # Safety Equipment
      case question_type
      when "multiple_choice"
        "What is the proper way to don a life jacket? (Question #{question_number})"
      when "short_answer"
        "How often should EPIRBs be tested? (Question #{question_number})"
      when "true_false"
        "Immersion suits are only required in Arctic waters. (Question #{question_number})"
      when "long_form"
        "Explain the maintenance requirements for all personal safety equipment and why regular inspection is crucial. (Question #{question_number})"
      end
    when 3 # Navigation Safety
      case question_type
      when "multiple_choice"
        "What is the rule of the road for collision avoidance? (Question #{question_number})"
      when "short_answer"
        "How should radar be used for navigation? (Question #{question_number})"
      when "true_false"
        "Bridge resource management is only important during emergencies. (Question #{question_number})"
      when "long_form"
        "Discuss the principles of bridge resource management and how they contribute to safe navigation. (Question #{question_number})"
      end
    when 4 # Cargo Safety
      case question_type
      when "multiple_choice"
        "How should dangerous goods be stowed? (Question #{question_number})"
      when "short_answer"
        "What are the requirements for cargo securing? (Question #{question_number})"
      when "true_false"
        "IMDG code only applies to container ships. (Question #{question_number})"
      when "long_form"
        "Explain the IMDG code requirements and how proper cargo segregation prevents accidents at sea. (Question #{question_number})"
      end
    end
    
    # Set up question-specific attributes
    question_attributes = {
      test: test,
      content: content,
      question_type: question_type
    }
    
    # Add options for multiple choice questions
    if question_type == "multiple_choice"
      question_attributes[:options] = case i
      when 0
        [["STCW Convention", "MARPOL", "SOLAS", "COLREGS"][j % 4],
         ["IMO", "UN", "ICAO", "WHO"][j % 4],
         ["16 years", "18 years", "21 years", "25 years"][j % 4],
         ["Safety of Life at Sea", "Standard of Living at Sea", "Safety of Life and Sea", "Standard of Life and Sea"][j % 4]]
      when 1
        [["Sound alarm and fight fire", "Evacuate immediately", "Call for help", "Use fire extinguisher"][j % 4],
         ["Continuous blast of whistle", "Three short blasts", "One long blast", "Two long blasts"][j % 4],
         ["Proceed to assigned station", "Stay in cabin", "Go to bridge", "Gather personal items"][j % 4],
         ["Use emergency frequencies", "Use regular radio", "Send email", "Use satellite phone"][j % 4]]
      when 2
        [["Put arms through armholes and fasten", "Wear over head", "Tie around waist", "Carry in hand"][j % 4],
         ["In cold water conditions", "In warm water", "Only in Arctic", "Never"][j % 4],
         ["Monthly", "Weekly", "Daily", "Yearly"][j % 4],
         ["Search and rescue transponder", "Emergency position indicator", "Life jacket", "Fire extinguisher"][j % 4]]
      when 3
        [["Keep to starboard in narrow channels", "Keep to port", "Stay in center", "Pass on either side"][j % 4],
         ["Monitor continuously", "Use occasionally", "Only at night", "Only in fog"][j % 4],
         ["Team coordination", "Individual decisions", "Captain only", "Pilot only"][j % 4],
         ["As specified in COLREGS", "As convenient", "Only at night", "Only in fog"][j % 4]]
      when 4
        [["According to segregation table", "Alphabetically", "By weight", "By color"][j % 4],
         ["Securely lashed", "Loosely tied", "Not secured", "Only in containers"][j % 4],
         ["Using stability calculations", "By eye", "By weight only", "Not calculated"][j % 4],
         ["Follow IMDG guidelines", "Use common sense", "Ask crew", "Not regulated"][j % 4]]
      end
      question_attributes[:correct_answer] = question_attributes[:options].first
    elsif question_type == "true_false"
      question_attributes[:correct_answer] = ["True", "False"][j % 2]
    elsif question_type == "short_answer"
      question_attributes[:correct_answer] = case i
      when 0 then ["STCW Convention", "Safety of Life at Sea", "MARPOL", "16 years", "IMO"][j % 5]
      when 1 then ["Sound alarm and fight fire", "Continuous blast of whistle", "Proceed to assigned station", "Use emergency frequencies", "Must function for 3 hours"][j % 5]
      when 2 then ["Put arms through armholes and fasten", "In cold water conditions", "Monthly", "Search and rescue transponder", "Regular inspection and testing"][j % 5]
      when 3 then ["Keep to starboard in narrow channels", "Monitor continuously", "Team coordination", "As specified in COLREGS", "Continuous and effective"][j % 5]
      when 4 then ["According to segregation table", "Securely lashed", "Using stability calculations", "Follow IMDG guidelines", "By qualified officer"][j % 5]
      end
      question_attributes[:max_length] = 100
    else # long_form
      question_attributes[:correct_answer] = "Detailed explanation covering key concepts, safety procedures, and regulatory requirements as specified in maritime regulations."
      question_attributes[:max_length] = 1000
    end
    
    Question.create!(question_attributes)
  end
end

# Final Assessment for Maritime Course
maritime_final = Test.create!(
  course: maritime_course,
  title: "Maritime Safety Fundamentals - Final Assessment",
  description: "Comprehensive final assessment covering all maritime safety topics. Must be passed to complete the course.",
  instructions: "This is a final assessment. You must complete all chapter assessments before taking this test. Honor statement required.",
  assessment_type: "final",
  time_limit: 120,
  honor_statement_required: true,
  max_attempts: 2,
  passing_score: 80.0,
  question_pool_size: 50
)

# Create 200 questions for final (4x requirement for 50 questions) with mixed question types
200.times do |i|
  question_number = i + 1
  topics = ["Maritime Law", "Emergency Response", "Safety Equipment", "Navigation Safety", "Cargo Safety"]
  topic = topics[i % 5]
  
  # Determine question type based on position (mix of types)
  question_type = case i % 4
  when 0 then "multiple_choice"
  when 1 then "short_answer"
  when 2 then "true_false"
  when 3 then "long_form"
  end
  
  content = case i % 5
  when 0 # Maritime Law
    case question_type
    when "multiple_choice"
      "What is the primary purpose of the STCW Convention? (Final Question #{question_number})"
    when "short_answer"
      "Which SOLAS chapter covers fire safety? (Final Question #{question_number})"
    when "true_false"
      "MARPOL Annex I regulates oil pollution from ships. (Final Question #{question_number})"
    when "long_form"
      "Explain the comprehensive role of the Master in ship security under the ISPS Code and how it integrates with other maritime safety regulations. (Final Question #{question_number})"
    end
  when 1 # Emergency Response
    case question_type
    when "multiple_choice"
      "What is the first action in a fire emergency? (Final Question #{question_number})"
    when "short_answer"
      "How should emergency signals be given? (Final Question #{question_number})"
    when "true_false"
      "Emergency power must be available for at least 3 hours. (Final Question #{question_number})"
    when "long_form"
      "Describe the complete emergency response protocol from initial alarm to post-emergency procedures, including crew coordination and safety measures. (Final Question #{question_number})"
    end
  when 2 # Safety Equipment
    case question_type
    when "multiple_choice"
      "What is the minimum number of life jackets required? (Final Question #{question_number})"
    when "short_answer"
      "When must immersion suits be provided? (Final Question #{question_number})"
    when "true_false"
      "SART devices have a range of 5 nautical miles. (Final Question #{question_number})"
    when "long_form"
      "Explain the maintenance and inspection requirements for all life-saving appliances and how they ensure crew safety in emergency situations. (Final Question #{question_number})"
    end
  when 3 # Navigation Safety
    case question_type
    when "multiple_choice"
      "What is the stand-on vessel's obligation? (Final Question #{question_number})"
    when "short_answer"
      "How should radar be used in restricted visibility? (Final Question #{question_number})"
    when "true_false"
      "Navigation lights must be displayed from sunset to sunrise. (Final Question #{question_number})"
    when "long_form"
      "Discuss the principles of bridge resource management and how effective lookout duties contribute to collision avoidance and safe navigation. (Final Question #{question_number})"
    end
  when 4 # Cargo Safety
    case question_type
    when "multiple_choice"
      "How should dangerous goods be segregated? (Final Question #{question_number})"
    when "short_answer"
      "What is the minimum securing strength? (Final Question #{question_number})"
    when "true_false"
      "IMDG classification has 9 different classes. (Final Question #{question_number})"
    when "long_form"
      "Explain the IMDG code requirements for dangerous goods handling and how proper cargo segregation and securing prevents maritime accidents. (Final Question #{question_number})"
    end
  end
  
  # Set up question-specific attributes
  question_attributes = {
    test: maritime_final,
    content: content,
    question_type: question_type
  }
  
  # Add options for multiple choice questions
  if question_type == "multiple_choice"
    question_attributes[:options] = case i % 5
    when 0
      [["Training standards", "Ship construction", "Cargo handling", "Navigation rules"][i % 4],
       ["Chapter II-2", "Chapter I", "Chapter III", "Chapter V"][i % 4],
       ["Oil pollution", "Air pollution", "Noise pollution", "Light pollution"][i % 4],
       ["Master", "Chief Officer", "Engineer", "Pilot"][i % 4]]
    when 1
      [["Sound alarm", "Evacuate", "Call for help", "Use extinguisher"][i % 4],
       ["Continuous blast", "Three blasts", "One blast", "No signal"][i % 4],
       ["Check muster list", "Stay in cabin", "Go to bridge", "Gather belongings"][i % 4],
       ["Use emergency frequencies", "Use regular radio", "Send email", "Use satellite"][i % 4]]
    when 2
      [["One per person", "Two per person", "One per cabin", "As needed"][i % 4],
       ["Cold water areas", "Warm water", "Tropical waters", "All waters"][i % 4],
       ["Remove safety pin", "Press button", "Pull cord", "Turn switch"][i % 4],
       ["5 nautical miles", "10 nautical miles", "3 nautical miles", "Unlimited"][i % 4]]
    when 3
      [["Maintain course and speed", "Change course", "Stop engines", "Reverse course"][i % 4],
       ["Monitor continuously", "Use occasionally", "Only at night", "Only in fog"][i % 4],
       ["Team coordination", "Individual decisions", "Captain only", "Pilot only"][i % 4],
       ["From sunset to sunrise", "24 hours", "Only at night", "Only in fog"][i % 4]]
    when 4
      [["By segregation table", "Alphabetically", "By weight", "By color"][i % 4],
       ["50% of cargo weight", "100% of cargo weight", "25% of cargo weight", "Not specified"][i % 4],
       ["KM minus KG", "KG minus KM", "KM plus KG", "KG plus KM"][i % 4],
       ["9 classes", "7 classes", "5 classes", "3 classes"][i % 4]]
    end
    question_attributes[:correct_answer] = question_attributes[:options].first
  elsif question_type == "true_false"
    question_attributes[:correct_answer] = ["True", "False"][i % 2]
  elsif question_type == "short_answer"
    question_attributes[:correct_answer] = case i % 5
    when 0 then ["Training standards", "Chapter II-2", "Oil pollution", "Master", "4 hours on, 8 hours off"][i % 5]
    when 1 then ["Sound alarm", "Continuous blast", "Check muster list", "Use emergency frequencies", "3 hours minimum"][i % 5]
    when 2 then ["One per person", "Cold water areas", "Remove safety pin", "5 nautical miles", "Monthly"][i % 5]
    when 3 then ["Maintain course and speed", "Monitor continuously", "Team coordination", "From sunset to sunrise", "Continuous and effective"][i % 5]
    when 4 then ["By segregation table", "50% of cargo weight", "KM minus KG", "9 classes", "Qualified officer"][i % 5]
    end
    question_attributes[:max_length] = 100
  else # long_form
    question_attributes[:correct_answer] = "Comprehensive explanation covering regulatory requirements, safety procedures, and practical implementation as specified in maritime regulations and industry best practices."
    question_attributes[:max_length] = 1000
  end
  
  Question.create!(question_attributes)
end

# Navigation Systems Test
navigation_test = Test.create!(
  course: navigation_course,
  title: "Electronic Navigation Systems Certification",
  description: "Certification test for electronic navigation systems including GPS, radar, and ECDIS.",
  instructions: "This certification test requires honor statement acceptance. Complete all questions within the time limit.",
  assessment_type: "final",
  time_limit: 90,
  honor_statement_required: true,
  max_attempts: 3,
  passing_score: 75.0,
  question_pool_size: 25
)

# Create 100 questions for navigation test (4x requirement) with mixed question types
100.times do |i|
  question_number = i + 1
  
  # Determine question type based on position (mix of types)
  question_type = case i % 4
  when 0 then "multiple_choice"
  when 1 then "short_answer"
  when 2 then "true_false"
  when 3 then "long_form"
  end
  
  content = case i % 4
  when 0 # GPS Systems
    case question_type
    when "multiple_choice"
      "What is the accuracy of GPS under normal conditions? (Question #{question_number})"
    when "short_answer"
      "How many satellites are needed for 3D positioning? (Question #{question_number})"
    when "true_false"
      "WAAS improves GPS accuracy. (Question #{question_number})"
    when "long_form"
      "Explain how GPS positioning works, including the role of satellites, signal processing, and factors that affect accuracy in maritime navigation. (Question #{question_number})"
    end
  when 1 # ECDIS Systems
    case question_type
    when "multiple_choice"
      "What does ECDIS stand for? (Question #{question_number})"
    when "short_answer"
      "How often should electronic charts be updated? (Question #{question_number})"
    when "true_false"
      "Paper charts are required as backup for ECDIS. (Question #{question_number})"
    when "long_form"
      "Describe the complete ECDIS system operation including chart data management, alarm handling, and backup procedures for safe navigation. (Question #{question_number})"
    end
  when 2 # Radar Systems
    case question_type
    when "multiple_choice"
      "What is the radar range resolution? (Question #{question_number})"
    when "short_answer"
      "How should radar be tuned for best performance? (Question #{question_number})"
    when "true_false"
      "Weather can cause radar interference. (Question #{question_number})"
    when "long_form"
      "Explain radar operation principles, echo interpretation techniques, and how to optimize radar performance for collision avoidance and navigation. (Question #{question_number})"
    end
  when 3 # AIS Systems
    case question_type
    when "multiple_choice"
      "What is AIS used for? (Question #{question_number})"
    when "short_answer"
      "How often does AIS transmit position? (Question #{question_number})"
    when "true_false"
      "AIS provides vessel identification information. (Question #{question_number})"
    when "long_form"
      "Discuss AIS functionality, data transmission protocols, and how AIS integration with other navigation systems enhances maritime safety and traffic management. (Question #{question_number})"
    end
  end
  
  # Set up question-specific attributes
  question_attributes = {
    test: navigation_test,
    content: content,
    question_type: question_type
  }
  
  # Add options for multiple choice questions
  if question_type == "multiple_choice"
    question_attributes[:options] = case i % 4
    when 0
      [["3-5 meters", "10-15 meters", "1-2 meters", "20-30 meters"][i % 4],
       ["4 satellites", "3 satellites", "5 satellites", "6 satellites"][i % 4],
       ["Improve accuracy", "Reduce cost", "Increase speed", "Save power"][i % 4],
       ["Every second", "Every minute", "Every 5 seconds", "Continuous"][i % 4]]
    when 1
      [["Electronic Chart Display", "Electronic Chart System", "Electronic Chart Device", "Electronic Chart Display and Information System"][i % 4],
       ["Weekly", "Monthly", "Daily", "Real-time"][i % 4],
       ["Chart data", "Weather data", "Traffic data", "Depth data"][i % 4],
       ["Immediately", "After delay", "Manually", "Never"][i % 4]]
    when 2
      [["0.1 nautical miles", "0.5 nautical miles", "1.0 nautical miles", "2.0 nautical miles"][i % 4],
       ["Auto tune", "Manual tune", "Fixed tune", "No tuning"][i % 4],
       ["Weather", "Sun", "Moon", "Stars"][i % 4],
       ["Size and shape", "Color only", "Speed only", "Distance only"][i % 4]]
    when 3
      [["Vessel identification", "Weather reporting", "Depth sounding", "Speed measurement"][i % 4],
       ["Every 3 seconds", "Every minute", "Every 5 seconds", "Continuous"][i % 4],
       ["Position and course", "Weather only", "Depth only", "Speed only"][i % 4],
       ["Immediately", "After delay", "Manually", "Never"][i % 4]]
    end
    question_attributes[:correct_answer] = question_attributes[:options].first
  elsif question_type == "true_false"
    question_attributes[:correct_answer] = ["True", "False"][i % 2]
  elsif question_type == "short_answer"
    question_attributes[:correct_answer] = case i % 4
    when 0 then ["3-5 meters", "4 satellites", "Improve accuracy", "Every second", "Atmospheric conditions"][i % 5]
    when 1 then ["Electronic Chart Display", "Weekly", "Chart data", "Immediately", "Paper charts"][i % 5]
    when 2 then ["0.1 nautical miles", "Auto tune", "Weather", "Size and shape", "0.5 nautical miles"][i % 5]
    when 3 then ["Vessel identification", "Every 3 seconds", "Position and course", "Immediately", "40 nautical miles"][i % 5]
    end
    question_attributes[:max_length] = 100
  else # long_form
    question_attributes[:correct_answer] = "Comprehensive technical explanation covering system principles, operational procedures, and safety considerations for maritime electronic navigation systems."
    question_attributes[:max_length] = 1000
  end
  
  Question.create!(question_attributes)
end

# Practice Test
practice_test = Test.create!(
  course: maritime_course,
  title: "Maritime Safety Practice Test",
  description: "Practice test for maritime safety fundamentals. No honor statement required.",
  instructions: "This is a practice test. Use it to prepare for the final assessment.",
  assessment_type: "practice",
  time_limit: 60,
  honor_statement_required: false,
  max_attempts: nil,
  passing_score: nil,
  question_pool_size: 20
)

# Create 80 practice questions (4x requirement) with mixed question types
80.times do |i|
  question_number = i + 1
  
  # Determine question type based on position (mix of types)
  question_type = case i % 4
  when 0 then "multiple_choice"
  when 1 then "short_answer"
  when 2 then "true_false"
  when 3 then "long_form"
  end
  
  content = case question_type
  when "multiple_choice"
    "What is the most important aspect of maritime safety? (Practice Question #{question_number})"
  when "short_answer"
    "What does SOLAS stand for? (Practice Question #{question_number})"
  when "true_false"
    "Regular safety drills are required on all commercial vessels. (Practice Question #{question_number})"
  when "long_form"
    "Explain the key principles of maritime safety and how they work together to ensure vessel and crew safety at sea. (Practice Question #{question_number})"
  end
  
  # Set up question-specific attributes
  question_attributes = {
    test: practice_test,
    content: content,
    question_type: question_type
  }
  
  # Add options for multiple choice questions
  if question_type == "multiple_choice"
    question_attributes[:options] = [
      ["Equipment", "Training", "Regulations", "All of the above"][i % 4],
      ["Training", "Equipment", "Procedures", "All of the above"][i % 4],
      ["Regulations", "Training", "Equipment", "All of the above"][i % 4],
      ["All of the above", "Equipment only", "Training only", "Regulations only"][i % 4]
    ]
    question_attributes[:correct_answer] = "All of the above"
  elsif question_type == "true_false"
    question_attributes[:correct_answer] = ["True", "False"][i % 2]
  elsif question_type == "short_answer"
    question_attributes[:correct_answer] = ["All of the above", "Safety of Life at Sea", "Training standards", "Equipment maintenance"][i % 4]
    question_attributes[:max_length] = 100
  else # long_form
    question_attributes[:correct_answer] = "Comprehensive explanation covering safety equipment, crew training, regulatory compliance, and emergency procedures as fundamental aspects of maritime safety."
    question_attributes[:max_length] = 1000
  end
  
  Question.create!(question_attributes)
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
      submitted: false,  # Create as not submitted first
      taken_at: 3.days.ago,
      score: 0,  # Will be calculated after answers are set
      honor_statement_accepted: false,
      start_time: 3.days.ago,
      end_time: 3.days.ago + 25.minutes,
      retake_number: 1
    )
    
    # Update questions with chosen answers (questions are auto-generated)
    attempt1.test_attempt_questions.each do |taq|
      taq.update!(chosen_answer: taq.question.correct_answer)
    end
    
    # Now submit the attempt
    attempt1.update!(
      submitted: true,
      score: attempt1.calculate_score
    )
    
  elsif student_index == 1
    # Student 2: Completed all chapters and final
    chapter_tests.each_with_index do |test, index|
      attempt = TestAttempt.create!(
        user: student,
        test: test,
        submitted: false,  # Create as not submitted first
        taken_at: (5 - index).days.ago,
        score: 0,  # Will be calculated after answers are set
        honor_statement_accepted: false,
        start_time: (5 - index).days.ago,
        end_time: (5 - index).days.ago + 25.minutes,
        retake_number: 1
      )
      
      # Update questions with chosen answers (questions are auto-generated)
      attempt.test_attempt_questions.each do |taq|
        taq.update!(chosen_answer: taq.question.correct_answer)
      end
      
      # Now submit the attempt
      attempt.update!(
        submitted: true,
        score: attempt.calculate_score
      )
    end
    
    # Final assessment - Passed
    final_attempt = TestAttempt.create!(
      user: student,
      test: maritime_final,
      submitted: false,  # Create as not submitted first
      taken_at: 1.day.ago,
      score: 0,  # Will be calculated after answers are set
      honor_statement_accepted: true,
      start_time: 1.day.ago,
      end_time: 1.day.ago + 115.minutes,
      retake_number: 1
    )
    
    # Update questions with chosen answers (questions are auto-generated)
    final_attempt.test_attempt_questions.each do |taq|
      taq.update!(chosen_answer: taq.question.correct_answer)
    end
    
    # Now submit the attempt
    final_attempt.update!(
      submitted: true,
      score: final_attempt.calculate_score
    )
    
  else
    # Student 3: Has some practice attempts
    practice_attempt = TestAttempt.create!(
      user: student,
      test: practice_test,
      submitted: false,  # Create as not submitted first
      taken_at: 2.days.ago,
      score: 0,  # Will be calculated after answers are set
      honor_statement_accepted: false,
      start_time: 2.days.ago,
      end_time: 2.days.ago + 55.minutes,
      retake_number: 1
    )
    
    # Update questions with chosen answers (questions are auto-generated)
    practice_attempt.test_attempt_questions.each do |taq|
      taq.update!(chosen_answer: taq.question.correct_answer)
    end
    
    # Now submit the attempt
    practice_attempt.update!(
      submitted: true,
      score: practice_attempt.calculate_score
    )
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
puts "   📝 Tests: #{Test.count} (#{Test.where(assessment_type: 'final').count} final, #{Test.where(assessment_type: 'chapter').count} chapter, #{Test.where(assessment_type: 'practice').count} practice)"
puts "   ❓ Questions: #{Question.count}"
puts "      📋 Multiple Choice: #{Question.where(question_type: 'multiple_choice').count}"
puts "      ✏️  Short Answer: #{Question.where(question_type: 'short_answer').count}"
puts "      📝 Long Form: #{Question.where(question_type: 'long_form').count}"
puts "      ✅ True/False: #{Question.where(question_type: 'true_false').count}"
puts "   🎯 Attempts: #{TestAttempt.count}"
puts "   💳 Payments: #{Payment.count}"
puts ""
puts "🔑 Login credentials:"
puts "   Admin: admin@seapasspro.com / password123"
puts "   Students: student1@seapasspro.com / password123 (has partial progress)"
puts "           student2@seapasspro.com / password123 (completed course)"
puts "           student3@seapasspro.com / password123 (practice only)"
puts ""
puts "🎯 New Features Tested:"
puts "   ✅ Multiple Question Types: Multiple Choice, Short Answer, Long Form, True/False"
puts "   ✅ Assessment Compliance: Honor statements, question pools, retake limits"
puts "   ✅ User Isolation: Users only see their own data"
puts "   ✅ Assessment Isolation: Course materials blocked during assessments"
puts "   ✅ Security Compliance: PII protection and audit logging"
puts "   ✅ Chapter Assessments: Time-managed course progression"
puts "   ✅ Automated Grading: With detailed feedback for all question types"
puts ""
puts "🌊 Welcome to Sea Pass Pro - Your Maritime Education Platform!"