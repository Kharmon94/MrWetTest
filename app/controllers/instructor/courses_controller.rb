module Instructor
  class CoursesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_course, only: [:show, :edit, :update, :destroy]
    authorize_resource

    def index
      @courses = Course.all.order(created_at: :desc)
      
      # Add enrollment statistics
      @courses = @courses.map do |course|
        course.define_singleton_method(:enrollment_count) do
          Payment.where(payable: self, status: 'succeeded').count
        end
        course
      end
    end

    def show
      @lessons = @course.lessons.order(:position)
      @enrollment_count = Payment.where(payable: @course, status: 'succeeded').count
      @recent_enrollments = Payment.where(payable: @course, status: 'succeeded')
                                  .includes(:user)
                                  .order(created_at: :desc)
                                  .limit(10)
    end

    def new
      @course = Course.new
    end

    def create
      @course = Course.new(course_params)
      
      if @course.save
        redirect_to instructor_course_path(@course), 
                    notice: 'Course was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @course.update(course_params)
        redirect_to instructor_course_path(@course), 
                    notice: 'Course was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      @course.destroy
      redirect_to instructor_courses_path, 
                  notice: 'Course was successfully deleted.'
    end

    private

    def set_course
      @course = Course.find(params[:id])
    end

    def course_params
      params.require(:course).permit(
        :title, 
        :description, 
        :price, 
        :time_managed, 
        :chapter_assessments_required,
        :thumbnail
      )
    end

  end
end
