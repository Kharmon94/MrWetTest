module Instructor
  class LessonsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_instructor
    before_action :set_course, only: [:index, :new, :create]
    before_action :set_lesson, only: [:show, :edit, :update, :destroy]

    def index
      @lessons = @course.lessons.order(:position)
    end

    def show
    end

    def new
      @lesson = @course.lessons.build
      @lesson.position = @course.lessons.count + 1
    end

    def create
      @lesson = @course.lessons.build(lesson_params)
      
      if @lesson.save
        redirect_to instructor_course_path(@course), 
                    notice: 'Lesson was successfully created.'
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @lesson.update(lesson_params)
        redirect_to instructor_course_path(@lesson.course), 
                    notice: 'Lesson was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      course = @lesson.course
      @lesson.destroy
      redirect_to instructor_course_path(course), 
                  notice: 'Lesson was successfully deleted.'
    end

    private

    def set_course
      @course = Course.find(params[:course_id])
    end

    def set_lesson
      @lesson = Lesson.find(params[:id])
    end

    def lesson_params
      params.require(:lesson).permit(:title, :content, :position)
    end

    def ensure_instructor
      unless current_user.has_role?(:instructor) || current_user.has_role?(:admin)
        redirect_to root_path, alert: "Access denied. Instructor privileges required."
      end
    end
  end
end
