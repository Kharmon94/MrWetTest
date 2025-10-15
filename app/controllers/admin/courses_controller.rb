class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def index
    @courses = Course.includes(:lessons).order(created_at: :desc)
    @courses = @courses.page(params[:page]) if defined?(Kaminari)
  end

  def show
    @lessons = @course.lessons.order(:position)
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(course_params)
    
    if @course.save
      redirect_to admin_course_path(@course), notice: 'Course was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to admin_course_path(@course), notice: 'Course was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @course.destroy
    redirect_to admin_courses_path, notice: 'Course was successfully deleted.'
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :thumbnail)
  end
end
