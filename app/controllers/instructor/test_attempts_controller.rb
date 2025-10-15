module Instructor
  class TestAttemptsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_test_attempt, only: [:show]
    authorize_resource

    def index
      @test_attempts = TestAttempt.includes(:user, :test)
                                 .where(submitted: true)
                                 .order(taken_at: :desc)
      
      # Filter by test if specified
      if params[:test_id].present?
        @test_attempts = @test_attempts.where(test_id: params[:test_id])
      end
      
      # Filter by date range if specified
      if params[:date_from].present?
        @test_attempts = @test_attempts.where('taken_at >= ?', Date.parse(params[:date_from]))
      end
      
      if params[:date_to].present?
        @test_attempts = @test_attempts.where('taken_at <= ?', Date.parse(params[:date_to]).end_of_day)
      end
      
      # Filter by score range if specified
      if params[:min_score].present?
        @test_attempts = @test_attempts.where('score >= ?', params[:min_score])
      end
      
      if params[:max_score].present?
        @test_attempts = @test_attempts.where('score <= ?', params[:max_score])
      end
      
      # Pagination - handle case where Kaminari might not be loaded
      if defined?(Kaminari)
        @test_attempts = @test_attempts.page(params[:page]).per(25)
        @total_attempts = @test_attempts.total_count
      else
        @test_attempts = @test_attempts.limit(25).offset((params[:page].to_i - 1) * 25)
        @total_attempts = @test_attempts.count
      end
      @average_score = @test_attempts.average(:score)&.round(1) || 0
      @pass_rate = calculate_pass_rate(@test_attempts)
      
      # Get filter options
      @tests = Test.all.order(:title)
      @date_from = params[:date_from]
      @date_to = params[:date_to]
      @min_score = params[:min_score]
      @max_score = params[:max_score]
      @selected_test_id = params[:test_id]
    end

    def show
      @questions = @test_attempt.test_attempt_questions.includes(:question)
    end

    private

    def set_test_attempt
      @test_attempt = TestAttempt.find(params[:id])
    end


    def calculate_pass_rate(attempts)
      return 0 if attempts.empty?
      
      total = attempts.count
      passed = attempts.select { |attempt| attempt.passed? }.count
      ((passed.to_f / total) * 100).round(1)
    end
  end
end
