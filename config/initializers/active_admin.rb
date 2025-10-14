# frozen_string_literal: true

ActiveAdmin.setup do |config|
  # == Site Title
  config.site_title = "Mr Wet Test Admin"

  # == User Authentication
  config.authentication_method = :authenticate_admin_user!

  # == Current User
  config.current_user_method = :current_admin_user

  # == Batch Actions
  config.batch_actions = true

  # == Attribute Filters
  config.filter_attributes = [
    :encrypted_password,
    :password,
    :password_confirmation
  ]
end
