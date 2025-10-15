class Admin::TestsController < Admin::BaseController
  before_action :set_test, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def index
    @tests = Test.includes(:questions).order(created_at: :desc)
    @tests = @tests.page(params[:page]) if defined?(Kaminari)
  end

  def show
    @questions = @test.questions.order(:created_at)
  end

  def new
    @test = Test.new
  end

  def create
    @test = Test.new(test_params)
    
    if @test.save
      redirect_to admin_test_path(@test), notice: 'Test was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @test.update(test_params)
      redirect_to admin_test_path(@test), notice: 'Test was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @test.destroy
    redirect_to admin_tests_path, notice: 'Test was successfully deleted.'
  end

  private

  def set_test
    @test = Test.find(params[:id])
  end

  def test_params
    params.require(:test).permit(:title, :description, :time_limit)
  end
end
