module AutoSessionTimeout
  
  def self.included(controller)
    controller.extend ClassMethods
  end
  
  module ClassMethods
    def auto_session_timeout(seconds=nil)
      protect_from_forgery except: [:active, :timeout]
      prepend_before_action do |c|
        if session_expired?(c) && !signing_in?(c)
          c.send :reset_session
        else
          unless c.request.original_url.start_with?(c.send(:active_url))
            offset = seconds || (current_user.respond_to?(:auto_timeout) ? current_user.auto_timeout : nil)
            c.session[:auto_session_expires_at] = Time.now + offset if offset && offset > 0
          end
        end
      end
    end
    
    def auto_session_timeout_actions
      define_method(:active) { render_session_status }
      define_method(:timeout) { render_session_timeout }
    end
  end
  
  def render_session_status
    response.headers["Etag"] = ""  # clear etags to prevent caching
    render plain: !!current_user, status: 200
  end
  
  def render_session_timeout
    flash[:notice] = t("devise.failure.timeout", default: "Your session has timed out.")
    redirect_to sign_in_path
  end

  private

  def signing_in?(c)
    c.request.env["PATH_INFO"] == sign_in_path && c.request.env["REQUEST_METHOD"] == "POST"
  end

  def session_expired?(c)
    c.session[:auto_session_expires_at].try(:<, Time.now)
  end

  def sign_in_path
    user_session_path
  rescue
    "/login"
  end
  
end

ActionController::Base.send :include, AutoSessionTimeout
