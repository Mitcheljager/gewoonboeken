class ApplicationController < ActionController::Base
  include RememberTokenHandler

  before_action :set_client_hints

  # after_action :track_action, only: [:index, :show, :new]

  helper_method :theme
  helper_method :theme_dark?
  helper_method :theme_light?
  helper_method :current_user
  helper_method :filter_params
  helper_method :any_filter_params?

  def theme
    cookies[:theme]
  end

  def theme_dark?
    theme === "dark" || request.headers["Sec-CH-Prefers-Color-Scheme"] === "dark"
  end

  def theme_light?
    !theme_dark?
  end

  def current_user
    return unless session[:user_id]

    @current_user ||= User.find_by(id: session[:user_id])
  end

  def filter_params
    params.permit(:available, :year_from, :year_to, :sort, :query, genres: [], conditions: [], formats: [], languages: [])
  end

  def any_filter_params?
    filter_params.to_h.any? { |_, v| v.present? }
  end

  private

  # Allow browsers to include their prefered color scheme. This only works for Chrome.
  # Will not work for the very first request, as this tells the browser to include it next time.
  # These headers are used in the theme_dark? method above.
  def set_client_hints
    response.set_header("Accept-CH", "Sec-CH-Prefers-Color-Scheme")
    response.set_header("Permissions-Policy", "ch-prefers-color-scheme=(self)")
    response.set_header("Vary", "Sec-CH-Prefers-Color-Scheme")
  end

  def redirect_unless_current_user
    redirect_to login_path, status: :see_other unless current_user.present?
  end

  def redirect_unless_admin
    redirect_to root_path, status: :see_other unless current_user&.admin?
  end

  # def track_action
  #   ahoy.track "Visit", request.path_parameters
  # end
end
