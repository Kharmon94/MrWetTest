module Admin
  class TestAttemptsController < ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin_user!

    # GET /admin/test_attempts
    def index
      @test_attempts = TestAttempt.includes(:user, :test).order(created_at: :desc)
      @test_attempts = @test_attempts.page(params[:page]) if defined?(Kaminari)
    end

    # GET /admin/test_attempts/:id
    def show
      @test_attempt = TestAttempt.includes(:user, :test, :test_attempt_questions).find(params[:id])
    end

    # GET /admin/test_attempts/:id/edit
    def edit
      @test_attempt = TestAttempt.find(params[:id])
    end

    # PATCH/PUT /admin/test_attempts/:id
    def update
      @test_attempt = TestAttempt.find(params[:id])
      
      if @test_attempt.update(test_attempt_params)
        redirect_to admin_test_attempt_path(@test_attempt), notice: 'Test attempt was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /admin/test_attempts/:id
    def destroy
      @test_attempt = TestAttempt.find(params[:id])
      @test_attempt.destroy
      redirect_to admin_test_attempts_path, notice: 'Test attempt was successfully deleted.'
    end

    private

    def test_attempt_params
      params.require(:test_attempt).permit(:score, :submitted, :honor_statement_accepted)
    end
  end
end
