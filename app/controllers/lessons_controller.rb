class LessonsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_lesson, only: [:show]
  before_action :ensure_enrolled_or_admin!

  # GET /courses/:course_id/lessons
  def index
    @lessons = @course.lessons.order(:position)
  end

  # GET /courses/:course_id/lessons/:id
  def show
    @previous_lesson = @course.lessons.where('position < ?', @lesson.position).order(:position).last
    @next_lesson = @course.lessons.where('position > ?', @lesson.position).order(:position).first
    @lesson_tests = @lesson.tests.order(:created_at)
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Course not found."
  end

  def set_lesson
    @lesson = @course.lessons.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to course_lessons_path(@course), alert: "Lesson not found."
  end

  def ensure_enrolled_or_admin!
    unless current_user.has_role?(:admin) || current_user.can_access?(@course)
      redirect_to course_path(@course), alert: "You must be enrolled in this course to access its lessons."
    end
  end
end
