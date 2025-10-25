class SettingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def index
    # Main settings dashboard
  end

  def profile
    # Profile management
  end

  def update_profile
    if @user.update(profile_params)
      redirect_to settings_profile_path, notice: 'Profile updated successfully.'
    else
      render :profile
    end
  end

  def preferences
    # Theme, notifications, language preferences
  end

  def update_preferences
    if @user.update(preferences_params)
      # Update theme preference in session
      session[:theme] = @user.theme_preference if @user.theme_preference.present?
      
      redirect_to settings_preferences_path, notice: 'Preferences updated successfully.'
    else
      render :preferences
    end
  end

  def security
    # Password change, 2FA, etc.
  end

  def update_password
    if @user.update_with_password(password_params)
      bypass_sign_in(@user)
      redirect_to settings_security_path, notice: 'Password updated successfully.'
    else
      render :security
    end
  end

  def notifications
    # Email and push notification preferences
  end

  def update_notifications
    if @user.update(notification_params)
      redirect_to settings_notifications_path, notice: 'Notification preferences updated successfully.'
    else
      render :notifications
    end
  end

  def account
    # Account deletion, data export, etc.
  end

  def export_data
    # Export user data (placeholder for future implementation)
    redirect_to settings_account_path, notice: 'Data export feature coming soon.'
  end

  def delete_account
    # Account deletion (placeholder for future implementation)
    redirect_to settings_account_path, alert: 'Account deletion feature coming soon. Please contact support.'
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:email, :first_name, :last_name, :bio, :avatar)
  end

  def preferences_params
    params.require(:user).permit(:theme_preference, :timezone, :language)
  end

  def password_params
    params.require(:user).permit(:current_password, :password, :password_confirmation)
  end

  def notification_params
    params.require(:user).permit(:email_notifications, :push_notifications)
  end
end
