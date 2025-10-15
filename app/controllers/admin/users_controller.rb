class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :impersonate, :send_reset_password]
  authorize_resource

  def index
    @users = User.includes(:roles, :test_attempts).order(created_at: :desc)
    
    # Filtering
    if params[:role].present?
      @users = @users.joins(:roles).where(roles: { name: params[:role] })
    end
    
    if params[:search].present?
      @users = @users.where("email ILIKE ?", "%#{params[:search]}%")
    end
    
    # Statistics
    @total_users = User.count
    @admin_users = User.joins(:roles).where(roles: { name: 'admin' }).count
    @instructor_users = User.joins(:roles).where(roles: { name: 'instructor' }).count
    @student_users = User.joins(:roles).where(roles: { name: 'student' }).count
    
    # Available roles for filtering
    @available_roles = Role.all
    
    # Pagination - handle case where Kaminari might not be loaded
    if defined?(Kaminari)
      @users = @users.page(params[:page]).per(20)
    else
      @users = @users.limit(20).offset((params[:page].to_i - 1) * 20)
    end
  end

  def show
    @test_attempts = @user.test_attempts.includes(:test).order(taken_at: :desc).limit(10)
    @payments = @user.payments.includes(:payable).order(created_at: :desc).limit(10)
    @purchased_courses = @user.purchased_courses.includes(:payments, :lessons)
    
    # Statistics for this user
    @total_attempts = @user.test_attempts.where(submitted: true).count
    @passed_attempts = @user.test_attempts.where(submitted: true).select { |ta| ta.passed? }.count
    @average_score = @user.test_attempts.where(submitted: true).average(:score)&.round(1) || 0
    @total_spent = @user.payments.where(status: 'succeeded').sum(:amount)
  end

  def edit
    @available_roles = Role.all
  end

  def update
    if @user.update(user_params)
      # Handle role updates
      if params[:user][:role_ids].present?
        @user.roles.clear
        params[:user][:role_ids].each do |role_id|
          role = Role.find(role_id) if role_id.present?
          @user.add_role(role.name) if role
        end
      end

      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      @available_roles = Role.all
      render :edit
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: 'You cannot delete your own account.'
    else
      @user.destroy
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end
  end

  def impersonate
    # Store current admin user in session for return
    session[:admin_user_id] = current_user.id
    sign_in @user
    redirect_to root_path, notice: "Now impersonating #{@user.email}"
  end

  def send_reset_password
    @user.send_reset_password_instructions
    redirect_to admin_user_path(@user), notice: 'Password reset instructions sent to user.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :theme_preference, 
                                :email_notifications, :push_notifications, :language, :timezone)
  end
end
