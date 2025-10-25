class Admin::LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin!
  before_action :set_lesson, only: [:show, :edit, :update, :destroy]

  # GET /admin/lessons
  def index
    @lessons = Lesson.includes(:course).order(:course_id, :position)
    @courses = Course.all.order(:title)
  end

  # GET /admin/lessons/:id
  def show
  end

  # GET /admin/lessons/new
  def new
    @lesson = Lesson.new
    @courses = Course.all.order(:title)
  end

  # GET /admin/lessons/:id/edit
  def edit
    @courses = Course.all.order(:title)
  end

  # POST /admin/lessons
  def create
    @lesson = Lesson.new(lesson_params)
    
    if @lesson.save
      redirect_to admin_lesson_path(@lesson), notice: "Lesson was successfully created."
    else
      @courses = Course.all.order(:title)
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /admin/lessons/:id
  def update
    if @lesson.update(lesson_params)
      redirect_to admin_lesson_path(@lesson), notice: "Lesson was successfully updated."
    else
      @courses = Course.all.order(:title)
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /admin/lessons/:id
  def destroy
    course = @lesson.course
    @lesson.destroy
    redirect_to admin_lessons_path, notice: "Lesson was successfully deleted."
  end

  private

  def set_lesson
    @lesson = Lesson.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_lessons_path, alert: "Lesson not found."
  end

  def lesson_params
    params.require(:lesson).permit(:title, :content, :position, :course_id)
  end

  def ensure_admin!
    unless current_user&.has_role?(:admin)
      redirect_to root_path, alert: "You must be an admin to access this page."
    end
  end
end
