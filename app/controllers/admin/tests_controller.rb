class Admin::TestsController < Admin::BaseController
  before_action :set_test, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def index
    @tests = Test.includes(:course, :lesson, :questions).order(created_at: :desc)
    @tests = @tests.page(params[:page]) if defined?(Kaminari)
  end

  def show
    @questions = @test.questions.order(:created_at)
    @recent_attempts = TestAttempt.where(test: @test, submitted: true)
                                 .includes(:user)
                                 .order(taken_at: :desc)
                                 .limit(10)
    
    # Statistics
    @total_attempts = TestAttempt.where(test: @test, submitted: true).count
    @pass_rate = calculate_pass_rate(@test)
    @average_score = calculate_average_score(@test)
  end

  def new
    @test = Test.new
    @courses = Course.all.order(:title)
    @lessons = Lesson.all.order(:title)
  end

  def create
    @test = Test.new(test_params)
    
    if @test.save
      redirect_to admin_test_path(@test), notice: 'Test was successfully created.'
    else
      render :new
    end
  end

  def edit
    @courses = Course.all.order(:title)
    @lessons = Lesson.all.order(:title)
  end

  def update
    if @test.update(test_params)
      redirect_to admin_test_path(@test), notice: 'Test was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @test.destroy
    redirect_to admin_tests_path, notice: 'Test was successfully deleted.'
  end

  private

  def set_test
    @test = Test.find(params[:id])
  end

  def test_params
    params.require(:test).permit(:title, :description, :instructions, :course_id, :lesson_id, 
                                :assessment_type, :time_limit, :honor_statement_required, :max_attempts, 
                                :passing_score, :question_pool_size)
  end

  def calculate_pass_rate(test)
    total_attempts = TestAttempt.where(test: test, submitted: true).count
    return 0 if total_attempts.zero?
    
    passed_attempts = TestAttempt.where(test: test, submitted: true)
                                .select { |attempt| attempt.passed? }.count
    ((passed_attempts.to_f / total_attempts) * 100).round(1)
  end

  def calculate_average_score(test)
    attempts = TestAttempt.where(test: test, submitted: true)
    return 0 if attempts.empty?
    (attempts.sum(:score) / attempts.count.to_f).round(1)
  end
end
