# app/controllers/courses_controller.rb
class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :ensure_admin!, only: [:new, :create, :edit, :update, :destroy]

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
    @courses = Course.all
    @show_all_courses = true
    render :index
  end

  # GET /courses/:id
  def show
    @lessons = @course.lessons.order(:position)
    @progress_data = @course.user_progress(current_user) if current_user
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
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Course not found."
  end

  def course_params
    params.require(:course).permit(:title, :description, :price)
  end

  def ensure_admin!
    unless current_user&.has_role?(:admin)
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
