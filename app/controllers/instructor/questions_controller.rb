module Instructor
  class QuestionsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_question, only: [:show, :edit, :update, :destroy]
    authorize_resource

    def index
      @questions = Question.includes(:test).order(created_at: :desc)
      
      # Filter by test if specified
      if params[:test_id].present?
        @questions = @questions.where(test_id: params[:test_id])
      end
      
      # Search functionality
      if params[:search].present?
        @questions = @questions.where(
          "content ILIKE ? OR correct_answer ILIKE ?", 
          "%#{params[:search]}%", 
          "%#{params[:search]}%"
        )
      end
      
      # Pagination - handle case where Kaminari might not be loaded
      if defined?(Kaminari)
        @questions = @questions.page(params[:page]).per(25)
      else
        @questions = @questions.limit(25).offset((params[:page].to_i - 1) * 25)
      end
      
      # Get filter options
      @tests = Test.all.order(:title)
      @search_term = params[:search]
      @selected_test_id = params[:test_id]
    end

    def show
    end

    def new
      @question = Question.new
      @tests = Test.all.order(:title)
    end

    def create
      @question = Question.new(question_params)
      
      if @question.save
        redirect_to instructor_question_path(@question), 
                    notice: 'Question was successfully created.'
      else
        @tests = Test.all.order(:title)
        render :new
      end
    end

    def edit
      @tests = Test.all.order(:title)
    end

    def update
      if @question.update(question_params)
        redirect_to instructor_question_path(@question), 
                    notice: 'Question was successfully updated.'
      else
        @tests = Test.all.order(:title)
        render :edit
      end
    end

    def destroy
      test_title = @question.test.title
      @question.destroy
      redirect_to instructor_questions_path, 
                  notice: "Question was successfully deleted from #{test_title}."
    end

    private

    def set_question
      @question = Question.find(params[:id])
    end

    def question_params
      params.require(:question).permit(:content, :correct_answer, :test_id)
    end
  end
end
