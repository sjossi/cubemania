class ApplicationController < ActionController::Base
  include Authentication

  before_filter :update_session_expiration_date, :set_time_zone, :store_return_to, :authenticate

  login :except => [:index, :show]

  protect_from_forgery

  filter_parameter_logging 'password'

  def rescue_action_in_public(exception)
    render :template => "errors/#{response_code_for_rescue(exception)}"
  end

  private
    def update_session_expiration_date
      unless ActionController::Base.session_options[:session_expires]
        ActionController::Base.session_options[:session_expires] = 1.month.from_now
      end
    end

    def set_time_zone
      if logged_in?
        Time.zone = current_user.time_zone
      elsif not cookies[:tz_offset].blank?
        Time.zone = TimeZone[-cookies[:tz_offset].to_i.minutes]
      end
    end

    def store_return_to
      store_location params[:return_to] unless params[:return_to].nil?
    end
    
    def authenticate
      if request.format.json?
        authenticate_or_request_with_http_basic("Cubemania API") do |user_name, password|
          @login = Login.new :name => user_name, :password => password
          @login.validate
        end
      end
    end
end