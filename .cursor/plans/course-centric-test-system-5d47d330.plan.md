<!-- 5d47d330-0a07-4ffe-ab30-cbb24f12fc79 6336b45b-2393-4482-b64a-dc6248595a08 -->
# Refactor Test System to be Course-Centric

## Database Changes

### Migration: Add course_id to tests table

Create migration to add `course_id` foreign key to `tests` table and add `test_type` field to distinguish between long/short tests.

**File:** `db/migrate/TIMESTAMP_add_course_id_and_test_type_to_tests.rb`

```ruby
class AddCourseIdAndTestTypeToTests < ActiveRecord::Migration[8.0]
  def change
    add_reference :tests, :course, null: false, foreign_key: true
    add_column :tests, :test_type, :string # 'long' or 'short'
    add_reference :tests, :lesson, null: true, foreign_key: true # Optional lesson association
    remove_column :tests, :price # Tests no longer have separate pricing
  end
end
```

## Model Updates

### Update Test model

**File:** `app/models/test.rb`

- Add `belongs_to :course`
- Add `belongs_to :lesson, optional: true`
- Remove payment-related methods (free?, paid?, formatted_price, stripe_price_id)
- Add validation for `test_type` (long/short)
- Update validations to make price-related validations conditional or remove them

### Update Course model

**File:** `app/models/course.rb`

- Add `has_many :tests, dependent: :destroy`
- Add methods: `long_tests`, `short_tests`, `lesson_tests(lesson)`
- Update `chapter_tests` and `final_assessment` methods to properly query associated tests
- Update `user_has_completed_all_chapters?` to check test completions through course association

### Update Lesson model

**File:** `app/models/lesson.rb`

- Add `has_many :tests, dependent: :nullify` (optional association)

## Routes Updates

### Remove standalone test routes

**File:** `config/routes.rb`

- Remove `resources :tests, only: [:index, :show]` from root level
- Remove standalone test assessment compliance routes
- Keep `namespace :tests` for test_attempts (accessed through courses)
- Nest test routes under courses: `resources :courses do; resources :tests; end`
- Update admin and instructor namespaces to keep test management routes

## Controller Updates

### Remove TestsController

**File:** `app/controllers/tests_controller.rb`

- Delete this file as tests will be accessed through courses

### Update CoursesController

**File:** `app/controllers/courses_controller.rb`

- Add actions to show course tests on course show page
- Ensure enrolled users can access course tests

### Create nested Tests under Courses

**File:** `app/controllers/courses/tests_controller.rb` (new)

- Create controller for managing tests within course context
- Actions: index (show all tests for a course), show (test details)
- Check course enrollment before allowing access

### Update Admin Tests Controller

**File:** `app/controllers/admin/tests_controller.rb`

- Update to require course_id when creating tests
- Update test_params to include course_id and test_type

### Update Instructor Tests Controller

**File:** `app/controllers/instructor/tests_controller.rb`

- Update to scope tests by course
- Update test_params to include course_id and test_type

## View Updates

### Update Course Show view

**File:** `app/views/courses/show.html.erb`

- Add section to display course tests (long and short)
- Show test availability based on enrollment
- Add buttons to start tests

### Remove Test views from root

- Delete `app/views/tests/index.html.erb`
- Delete `app/views/tests/show.html.erb`

### Create nested test views under courses

**File:** `app/views/courses/tests/index.html.erb` (new)

- List all tests for the course

**File:** `app/views/courses/tests/show.html.erb` (new)

- Show test details with start button

### Update Admin Test views

**Files:** `app/views/admin/tests/new.html.erb`, `app/views/admin/tests/edit.html.erb`

- Add course selector dropdown
- Add test_type selector (long/short)
- Add optional lesson selector
- Remove price field

### Update Instructor Test views

**Files:** `app/views/instructor/tests/new.html.erb`, `app/views/instructor/tests/edit.html.erb`

- Add course selector dropdown
- Add test_type selector (long/short)
- Add optional lesson selector

## Navigation Updates

### Update navbar

**File:** `app/views/layouts/application.html.erb`

- Remove "Testing" dropdown entirely
- Tests will be accessed through course pages only

## Ability/Permissions Updates

### Update CanCanCan abilities

**File:** `app/models/ability.rb`

- Update test permissions to check course enrollment
- Students can access tests only for enrolled courses
- Instructors can manage tests for their courses
- Admins can manage all tests

## Seeds File Updates

### Update seed data

**File:** `db/seeds.rb`

- Update test creation to include course_id and test_type
- Create both long and short tests for each course
- Optionally create lesson-specific tests
- Remove test payment records
- Keep test_attempts associated with course tests

### To-dos

- [ ] Create migration to add course_id, test_type, and lesson_id to tests; remove price
- [ ] Update Test model with course association, remove payment methods, add test_type validation
- [ ] Update Course model with tests association and helper methods for long/short tests
- [ ] Update Lesson model to allow optional test association
- [ ] Remove standalone test routes, nest tests under courses, update namespaced routes
- [ ] Delete standalone TestsController
- [ ] Create Courses::TestsController for course-scoped test access
- [ ] Update Admin::TestsController to require course_id and test_type
- [ ] Update Instructor::TestsController to scope by course
- [ ] Update courses/show.html.erb to display course tests
- [ ] Create courses/tests views for index and show
- [ ] Update admin test forms with course selector and test_type field
- [ ] Update instructor test forms with course selector and test_type field
- [ ] Remove Testing dropdown from navigation
- [ ] Update CanCanCan permissions to check course enrollment for test access
- [ ] Update seed file to create course-associated tests with test_type