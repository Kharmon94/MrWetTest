class Admin::CoursesController < Admin::BaseController
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def index
    @courses = Course.includes(:lessons).order(created_at: :desc)
    
    # Filtering
    if params[:price_filter].present?
      case params[:price_filter]
      when 'free'
        @courses = @courses.where(price: [nil, 0])
      when 'paid'
        @courses = @courses.where('price > 0')
      end
    end
    
    if params[:search].present?
      @courses = @courses.where("title ILIKE ? OR description ILIKE ?", 
                               "%#{params[:search]}%", "%#{params[:search]}%")
    end
    
    # Statistics
    @total_courses = Course.count
    @free_courses = Course.where(price: [nil, 0]).count
    @paid_courses = Course.where('price > 0').count
    @time_managed_courses = Course.where(time_managed: true).count
    @total_revenue = Payment.where(payable_type: 'Course', status: 'succeeded').sum(:amount)
    
    # Pagination - handle case where Kaminari might not be loaded
    if defined?(Kaminari)
      @courses = @courses.page(params[:page]).per(20)
    else
      @courses = @courses.limit(20).offset((params[:page].to_i - 1) * 20)
    end
  end

  def show
    @lessons = @course.lessons.order(:position)
    @enrollments = @course.payments.where(status: 'succeeded').count
    @revenue = @course.payments.where(status: 'succeeded').sum(:amount)
    @recent_enrollments = @course.payments.includes(:user)
                               .where(status: 'succeeded')
                               .order(created_at: :desc)
                               .limit(10)
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
    params.require(:course).permit(:title, :description, :price, :time_managed, 
                                  :chapter_assessments_required, :thumbnail)
  end
end
