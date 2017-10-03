class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_action :verify_authenticity_token
  before_action :configure_permitted_params, if: :devise_controller?

  def index

  end

  def check_login
    redirect_to root_path if current_admin.nil?
  end

  protected

  def configure_permitted_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:town_id,:name])
  end

end
