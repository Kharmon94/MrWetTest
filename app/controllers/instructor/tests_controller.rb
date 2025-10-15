module Instructor
  class TestsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_instructor
    before_action :set_test, only: [:show, :edit, :update, :destroy]

    def index
      @tests = Test.all.order(created_at: :desc)
      
      # Add completion statistics
      @tests = @tests.map do |test|
        test.define_singleton_method(:completion_count) do
          TestAttempt.where(test: self, submitted: true).count
        end
        test.define_singleton_method(:average_score) do
          attempts = TestAttempt.where(test: self, submitted: true)
          return 0 if attempts.empty?
          (attempts.sum(:score) / attempts.count.to_f).round(1)
        end
        test
      end
    end

    def show
      @questions = @test.questions.order(:id)
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
    end

    def create
      @test = Test.new(test_params)
      
      if @test.save
        redirect_to instructor_test_path(@test), 
                    notice: 'Test was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @test.update(test_params)
        redirect_to instructor_test_path(@test), 
                    notice: 'Test was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @test.destroy
      redirect_to instructor_tests_path, 
                  notice: 'Test was successfully deleted.'
    end

    private

    def set_test
      @test = Test.find(params[:id])
    end

    def test_params
      params.require(:test).permit(
        :title, 
        :description, 
        :instructions,
        :price, 
        :assessment_type,
        :time_limit,
        :honor_statement_required,
        :max_attempts,
        :passing_score,
        :question_pool_size
      )
    end

    def ensure_instructor
      unless current_user.has_role?(:instructor) || current_user.has_role?(:admin)
        redirect_to root_path, alert: "Access denied. Instructor privileges required."
      end
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
end
