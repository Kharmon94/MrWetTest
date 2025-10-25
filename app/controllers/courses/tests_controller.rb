class Courses::TestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :ensure_enrolled_or_admin!

  def index
    @tests = @course.tests.order(:title)
  end

  def show
    @test = @course.tests.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to course_path(@course), alert: "Test not found."
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to courses_path, alert: "Course not found."
  end

  def ensure_enrolled_or_admin!
    unless current_user.has_role?(:admin) || current_user.can_access?(@course)
      redirect_to course_path(@course), alert: "You must be enrolled in this course to access its tests."
    end
  end
end
