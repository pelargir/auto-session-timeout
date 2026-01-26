require File.dirname(__FILE__) + '/test_helper'

describe AutoSessionTimeout do

  class MainApp
    def active_url
      "http://example.com/active"
    end
  end

  class StubController
    include AutoSessionTimeout

    def main_app
      MainApp.new
    end

    def user_session_path
      "/users/sign_in"
    end
  end

  class StubControllerWithoutRoutes
    include AutoSessionTimeout

    def main_app
      raise NoMethodError, "undefined method `active_url'"
    end

    def user_session_path
      raise NoMethodError, "undefined method `user_session_path'"
    end
  end

  # Stub for testing session_expired? and signing_in?
  class StubSession < Hash
  end

  class StubRequest
    attr_accessor :env, :original_url

    def initialize(path_info: "/", request_method: "GET", original_url: "http://example.com/")
      @env = {
        "PATH_INFO" => path_info,
        "REQUEST_METHOD" => request_method
      }
      @original_url = original_url
    end
  end

  class StubControllerWithSession
    include AutoSessionTimeout

    attr_accessor :session, :request, :session_was_reset

    def initialize
      @session = StubSession.new
      @request = StubRequest.new
      @session_was_reset = false
    end

    def main_app
      MainApp.new
    end

    def user_session_path
      "/users/sign_in"
    end

    def reset_session
      @session_was_reset = true
      @session.clear
    end
  end

  class StubUser
    attr_accessor :auto_timeout

    def initialize(auto_timeout: nil)
      @auto_timeout = auto_timeout
    end

    def respond_to?(method)
      method.to_sym == :auto_timeout || super
    end
  end

  class StubControllerWithCurrentUser < StubControllerWithSession
    attr_accessor :current_user

    def initialize
      super
      @current_user = nil
    end
  end

  describe "#active_url" do
    it "returns main_app.active_url when available" do
      controller = StubController.new
      assert_equal "http://example.com/active", controller.send(:active_url)
    end

    it "falls back to /active when main_app.active_url is not available" do
      controller = StubControllerWithoutRoutes.new
      assert_equal "/active", controller.send(:active_url)
    end
  end

  describe "#sign_in_path" do
    it "returns user_session_path when available" do
      controller = StubController.new
      assert_equal "/users/sign_in", controller.send(:sign_in_path)
    end

    it "falls back to /login when user_session_path is not available" do
      controller = StubControllerWithoutRoutes.new
      assert_equal "/login", controller.send(:sign_in_path)
    end
  end

  describe "#session_expired?" do
    it "returns true when session has expired" do
      controller = StubControllerWithSession.new
      controller.session[:auto_session_expires_at] = Time.now - 60
      assert controller.send(:session_expired?, controller)
    end

    it "returns false when session has not expired" do
      controller = StubControllerWithSession.new
      controller.session[:auto_session_expires_at] = Time.now + 60
      refute controller.send(:session_expired?, controller)
    end

    it "returns falsy when no expiration is set" do
      controller = StubControllerWithSession.new
      refute controller.send(:session_expired?, controller)
    end
  end

  describe "#signing_in?" do
    it "returns true for POST to sign_in_path" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/users/sign_in", request_method: "POST")
      assert controller.send(:signing_in?, controller)
    end

    it "returns false for GET to sign_in_path" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/users/sign_in", request_method: "GET")
      refute controller.send(:signing_in?, controller)
    end

    it "returns false for POST to other paths" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/other", request_method: "POST")
      refute controller.send(:signing_in?, controller)
    end
  end

  describe "#handle_session_reset" do
    it "calls reset_session on the controller" do
      controller = StubControllerWithSession.new
      controller.session[:auto_session_expires_at] = Time.now + 60
      controller.session[:user_id] = 123

      refute controller.session_was_reset
      controller.send(:handle_session_reset, controller)

      assert controller.session_was_reset
    end
  end

  describe "session timeout behavior" do
    # Helper to simulate the before_action logic
    def simulate_before_action(controller, seconds = nil)
      if controller.send(:session_expired?, controller) && !controller.send(:signing_in?, controller)
        controller.send(:handle_session_reset, controller)
      else
        unless controller.request.original_url.start_with?(controller.send(:active_url))
          current_user = controller.respond_to?(:current_user) ? controller.current_user : nil
          offset = seconds || (current_user&.respond_to?(:auto_timeout) ? current_user.auto_timeout : nil)
          controller.session[:auto_session_expires_at] = Time.now + offset if offset && offset > 0
        end
      end
    end

    it "resets session when expired and not signing in" do
      controller = StubControllerWithSession.new
      controller.session[:auto_session_expires_at] = Time.now - 60
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET")

      simulate_before_action(controller)

      assert controller.session_was_reset
    end

    it "does not reset session when signing in even if expired" do
      controller = StubControllerWithSession.new
      controller.session[:auto_session_expires_at] = Time.now - 60
      controller.request = StubRequest.new(path_info: "/users/sign_in", request_method: "POST")

      simulate_before_action(controller)

      refute controller.session_was_reset
    end

    it "does not reset session when not expired" do
      controller = StubControllerWithSession.new
      controller.session[:auto_session_expires_at] = Time.now + 60
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET")

      simulate_before_action(controller, 300)

      refute controller.session_was_reset
    end

    it "sets session expiration time with given seconds" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET", original_url: "http://example.com/dashboard")

      before_time = Time.now
      simulate_before_action(controller, 300)
      after_time = Time.now

      assert controller.session[:auto_session_expires_at] >= before_time + 300
      assert controller.session[:auto_session_expires_at] <= after_time + 300
    end

    it "uses current_user.auto_timeout when available" do
      controller = StubControllerWithCurrentUser.new
      controller.current_user = StubUser.new(auto_timeout: 600)
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET", original_url: "http://example.com/dashboard")

      before_time = Time.now
      simulate_before_action(controller)
      after_time = Time.now

      assert controller.session[:auto_session_expires_at] >= before_time + 600
      assert controller.session[:auto_session_expires_at] <= after_time + 600
    end

    it "does not update expiration for active_url requests" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(
        path_info: "/active",
        request_method: "GET",
        original_url: "http://example.com/active"
      )

      simulate_before_action(controller, 300)

      assert_nil controller.session[:auto_session_expires_at]
    end

    it "does not set expiration when seconds is nil and no user timeout" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET", original_url: "http://example.com/dashboard")

      simulate_before_action(controller, nil)

      assert_nil controller.session[:auto_session_expires_at]
    end

    it "does not set expiration when seconds is zero" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET", original_url: "http://example.com/dashboard")

      simulate_before_action(controller, 0)

      assert_nil controller.session[:auto_session_expires_at]
    end

    it "does not set expiration when seconds is negative" do
      controller = StubControllerWithSession.new
      controller.request = StubRequest.new(path_info: "/dashboard", request_method: "GET", original_url: "http://example.com/dashboard")

      simulate_before_action(controller, -10)

      assert_nil controller.session[:auto_session_expires_at]
    end
  end

end
