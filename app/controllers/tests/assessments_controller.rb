module Tests
  class AssessmentsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource

    # GET /assessments
    def index
      # Cancancan will automatically load assessments that the current user is authorized to see.
      @assessments = current_user.assessments.order(taken_at: :desc)
    end

    # GET /assessments/new?course_id=:course_id
    def new
      @course = Course.find(params[:course_id])
    end

    # POST /assessments
    def create
      unless params[:honor_statement] == '1'
        flash[:alert] = "You must agree to the honor statement to proceed."
        redirect_to new_assessment_path(course_id: params[:course_id]) and return
      end

      @course = Course.find(params[:course_id])
      @assessment = current_user.assessments.create(course: @course, taken_at: Time.current, submitted: false)

      question_count = 10
      pool = @course.questions.to_a
      if pool.size < question_count * 4
        flash[:alert] = "Not enough questions in the pool to generate the assessment."
        redirect_to root_path and return
      end

      selected_questions = pool.sample(question_count)
      selected_questions.each do |question|
        @assessment.assessment_questions.create(question: question)
      end

      redirect_to edit_assessment_path(@assessment)
    end

    # GET /assessments/:id/edit
    def edit
      if @assessment.submitted?
        flash[:alert] = "This assessment has already been submitted."
        redirect_to assessment_path(@assessment)
      end
      # The @assessment is loaded and authorized by Cancancan.
    end

    # PATCH/PUT /assessments/:id
    def update
      if @assessment.submitted?
        flash[:alert] = "This assessment has already been submitted."
        redirect_to assessment_path(@assessment) and return
      end

      params[:assessment_questions]&.each do |aq_id, answer|
        aq = @assessment.assessment_questions.find(aq_id)
        aq.update(chosen_answer: answer)
      end

      @assessment.update(submitted: true, score: @assessment.calculate_score)

      redirect_to assessment_path(@assessment)
    end

    # GET /assessments/:id
    def show
      # @assessment is loaded and authorized by Cancancan.
    end
  end
end
