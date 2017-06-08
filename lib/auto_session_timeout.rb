module AutoSessionTimeout

  def self.included(controller)
    controller.extend ClassMethods
  end

  module ClassMethods
    def auto_session_timeout(seconds=nil)
      prepend_before_action do |c|
        if c.session[:auto_session_expires_at] && c.session[:auto_session_expires_at] < Time.now
          old_session = session[:_csrf_token]
          c.send :reset_session
          session[:_csrf_token] = old_session
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
    flash[:notice] = "Your session has timed out."
    redirect_to "/login"
  end

end

ActionController::Base.send :include, AutoSessionTimeout
