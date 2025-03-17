module Tests
  class TestAttemptsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_test_attempt, only: [:show, :edit, :update]

    # GET /tests/test_attempts
    def index
      @test_attempts = current_user.test_attempts.order(taken_at: :desc)
    end

    # GET /tests/test_attempts/new?test_id=:test_id
    def new
      @test = Test.find(params[:test_id])
      # Display instructions and honor statement for the test.
    end

    # POST /tests/test_attempts
    def create
      unless params[:honor_statement] == '1'
        flash[:alert] = "You must agree to the honor statement to proceed."
        redirect_to new_tests_test_attempt_path(test_id: params[:test_id]) and return
      end

      @test = Test.find(params[:test_id])
      @test_attempt = current_user.test_attempts.create(test: @test, taken_at: Time.current, submitted: false)

      # Define the number of questions for the test (example: 10)
      question_count = 10
      pool = @test.questions.to_a
      if pool.size < question_count * 4
        flash[:alert] = "Not enough questions available to generate the test."
        redirect_to tests_path and return
      end

      selected_questions = pool.sample(question_count)
      selected_questions.each do |question|
        @test_attempt.test_attempt_questions.create(question: question)
      end

      redirect_to edit_tests_test_attempt_path(@test_attempt)
    end

    # GET /tests/test_attempts/:id/edit
    def edit
      if @test_attempt.submitted?
        flash[:alert] = "This test attempt has already been submitted."
        redirect_to tests_test_attempt_path(@test_attempt) and return
      end
      # Render form for answering questions.
    end

    # PATCH/PUT /tests/test_attempts/:id
    def update
      if @test_attempt.submitted?
        flash[:alert] = "This test attempt has already been submitted."
        redirect_to tests_test_attempt_path(@test_attempt) and return
      end

      params[:test_attempt_questions]&.each do |taq_id, answer|
        taq = @test_attempt.test_attempt_questions.find(taq_id)
        taq.update(chosen_answer: answer)
      end

      @test_attempt.update(submitted: true, score: @test_attempt.calculate_score)
      redirect_to tests_test_attempt_path(@test_attempt)
    end

    # GET /tests/test_attempts/:id
    def show
      # Display the test attempt results.
    end

    private

    def set_test_attempt
      @test_attempt = current_user.test_attempts.find(params[:id])
    end
  end
end
