class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  authorize_resource

  def index
    @users = User.includes(:roles).order(created_at: :desc)
    @users = @users.page(params[:page]) if defined?(Kaminari)
  end

  def show
  end

  def edit
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
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end
end
