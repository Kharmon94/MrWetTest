class Courses::TestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course

  def index
    @tests = @course.tests
  end

  def show
    @test = @course.tests.find(params[:id])
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end
end