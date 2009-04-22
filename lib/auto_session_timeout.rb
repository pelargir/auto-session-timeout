module AutoSessionTimeout
  
  def self.included(controller)
    controller.extend ClassMethods
    controller.hide_action :render_auto_session_timeout
  end
  
  module ClassMethods
    def auto_session_timeout(seconds)
      prepend_before_filter do |c|
        if c.session[:auto_session_expires_at] && c.session[:auto_session_expires_at] < Time.now
          c.send :reset_session
        else
          unless c.params[:controller] == "sessions" && c.params[:action] == "active"
            c.session[:auto_session_expires_at] = Time.now + seconds
          end
        end
      end
    end
  end
  
  def render_auto_session_timeout
    response.headers["Etag"] = nil  # clear etags to prevent caching
    render :text => logged_in?, :status => 200
  end
  
end

ActionController::Base.send :include, AutoSessionTimeout