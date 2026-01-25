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

end
