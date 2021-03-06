class ApplicationController < ActionController::Base
  protect_from_forgery 

  before_filter :miniprofiler
    
  #filter_parameter_logging :password, :password_confirmation # there are underscores  
  helper_method :current_user_session, :current_user, :signed_in?

  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  private
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
    
    def signed_in?
      !current_user.nil?
    end
    
    def require_user
      logger.debug "ApplicationController::require_user"
      unless current_user
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to login_url
        return false
      end
    end

    def require_no_user(notice = "You must be logged out to access this page")
      logger.debug "ApplicationController::require_no_user"
      if current_user
        store_location
        flash[:notice] = notice
        redirect_to root_url
        return false
      end
    end

    def store_location
      session[:return_to] = request.url
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def record_not_found
      render :text => "404 Not Found", :status => 404
    end
    
    def miniprofiler
      Rack::MiniProfiler.authorize_request # if user.admin?
    end

end
