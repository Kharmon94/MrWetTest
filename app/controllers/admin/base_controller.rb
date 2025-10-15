class Admin::BaseController < ApplicationController
  include CanCan::ControllerAdditions
  
  before_action :authenticate_user!
  before_action :ensure_admin!

  private

  def ensure_admin!
    unless current_user&.has_role?(:admin)
      flash[:alert] = "You don't have permission to access this area."
      redirect_to root_path
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = "Access denied. #{exception.message}"
    redirect_to admin_root_path
  end
end
