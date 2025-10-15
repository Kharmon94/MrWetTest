# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]

  # GET /courses
  def index
    if user_signed_in?
      if current_user.has_role?(:admin)
        # Admins see all courses
        @courses = Course.all
        @show_all_courses = true
      else
        # Regular users see their purchased/enrolled courses
        @courses = current_user.purchased_courses
        @show_all_courses = false
      end
    else
      # Guests see all courses (but can't access them)
      @courses = Course.all
      @show_all_courses = true
    end
  end

  # GET /courses/browse
  def browse
    if user_signed_in? && !current_user.has_role?(:admin)
      @courses = Course.all
      @show_all_courses = true
      render :index
    else
      redirect_to courses_path
    end
  end

  # GET /courses/:id
  def show
    # Optionally, you could load associated lessons here:
    # @lessons = @course.lessons.order(:position)
  end

  # GET /courses/new
  def new
    @course = Course.new
  end

  # POST /courses
  def create
    @course = Course.new(course_params)
    if @course.save
      redirect_to @course, notice: "Course was successfully created."
    else
      render :new
    end
  end

  # GET /courses/:id/edit
  def edit; end

  # PATCH/PUT /courses/:id
  def update
    if @course.update(course_params)
      redirect_to @course, notice: "Course was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /courses/:id
  def destroy
    @course.destroy
    redirect_to courses_url, notice: "Course was successfully destroyed."
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :price)
  end
end
