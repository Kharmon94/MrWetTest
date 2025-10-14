class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  
  private

  def authenticate_admin_user!
    # Ensure a user is logged in first
    authenticate_user!
    # Check if the current user has an admin role
    unless current_user&.has_role?(:admin)
      flash[:alert] = "You are not authorized to access this page."
      redirect_to root_path and return
    end
  end

  def current_admin_user
    # Return the current user if they're an admin, otherwise nil.
    current_user if current_user&.has_role?(:admin)
  end
end
