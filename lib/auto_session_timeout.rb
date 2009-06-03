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
          unless c.send(:active_url) == c.url_for(c.params)
            c.session[:auto_session_expires_at] = Time.now + seconds
          end
        end
      end
    end
  end
  
  def render_session_status
    response.headers["Etag"] = ""  # clear etags to prevent caching
    render :text => logged_in?, :status => 200
  end
  
  def render_session_timeout
    flash[:notice] = "Your session has timed out."
    redirect_to "/login"
  end
  
end

ActionController::Base.send :include, AutoSessionTimeout