class Admin::QuestionsController < Admin::BaseController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def index
    @questions = Question.includes(:test).order(created_at: :desc)
    @questions = @questions.page(params[:page]) if defined?(Kaminari)
  end

  def show
  end

  def new
    @question = Question.new
    @tests = Test.all
  end

  def create
    @question = Question.new(question_params)
    
    if @question.save
      redirect_to admin_question_path(@question), notice: 'Question was successfully created.'
    else
      @tests = Test.all
      render :new
    end
  end

  def edit
    @tests = Test.all
  end

  def update
    if @question.update(question_params)
      redirect_to admin_question_path(@question), notice: 'Question was successfully updated.'
    else
      @tests = Test.all
      render :edit
    end
  end

  def destroy
    @question.destroy
    redirect_to admin_questions_path, notice: 'Question was successfully deleted.'
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    permitted_params = params.require(:question).permit(:test_id, :content, :correct_answer, :question_type, :max_length, options: [])
    
    # Handle multiple choice options
    if permitted_params[:options].present?
      permitted_params[:options] = permitted_params[:options].reject(&:blank?)
    end
    
    # Set default question type if not provided
    permitted_params[:question_type] ||= 'short_answer'
    
    permitted_params
  end
end
