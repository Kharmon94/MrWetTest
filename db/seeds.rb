# db/seeds.rb

puts "➡️ Clearing old data..."
TestAttemptQuestion.delete_all
TestAttempt.delete_all
Question.delete_all
Test.delete_all
Lesson.delete_all
Course.delete_all
User.delete_all
Role.delete_all

puts "➡️ Seeding users..."
student = User.create!(email: "student@example.com", password: "password")
admin   = User.create!(email: "admin@example.com", password: "password")
admin.add_role(:admin)

puts "➡️ Seeding courses and lessons..."
course1 = Course.create!(title: "Rails Basics", description: "Intro to Rails", price: 49.99)
Lesson.create!(course: course1, title: "Getting Started", content: "Rails overview", position: 1)
Lesson.create!(course: course1, title: "Models & Migrations", content: "ActiveRecord fundamentals", position: 2)

course2 = Course.create!(title: "Advanced Rails", description: "Deep dive", price: 79.99)
Lesson.create!(course: course2, title: "Performance Tuning", content: "Caching & indexing", position: 1)
Lesson.create!(course: course2, title: "Scaling Rails", content: "Horizontal scaling patterns", position: 2)

puts "➡️ Seeding tests and questions..."
test1 = Test.create!(title: "Rails Fundamentals Test", description: "Basic Rails knowledge", price: 19.99, instructions: "Answer all questions")
20.times { |i| Question.create!(test: test1, content: "What is Rails? Q#{i+1}", correct_answer: "A web framework") }

test2 = Test.create!(title: "Advanced Rails Test", description: "In‑depth Rails topics", price: 29.99, instructions: "Answer thoroughly")
20.times { |i| Question.create!(test: test2, content: "Explain advanced concept #{i+1}", correct_answer: "Detailed answer") }

puts "➡️ Seeding test attempts..."
# In‑progress attempt
ta1 = TestAttempt.create!(user: student, test: test1, submitted: false, taken_at: Time.current)

# Completed attempt with random answers
ta2 = TestAttempt.create!(user: student, test: test1, submitted: true, taken_at: 1.day.ago)
test1.questions.sample(10).each do |q|
  ta2.test_attempt_questions.create!(question: q, chosen_answer: q.correct_answer)
end
ta2.update!(score: ta2.calculate_score)

puts "✅ Seed complete!"
AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?