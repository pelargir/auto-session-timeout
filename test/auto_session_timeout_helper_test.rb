require File.dirname(__FILE__) + '/test_helper'

describe AutoSessionTimeoutHelper do

  class StubView
    include AutoSessionTimeoutHelper
    include ActionView::Helpers::JavaScriptHelper
    include ActionView::Helpers::TagHelper

    def timeout_path
      "/timeout"
    end

    def active_path
      "/active"
    end
  end

  subject { StubView.new }

  describe "#auto_session_timeout_js" do
    it "returns correct JS" do
      js = subject.auto_session_timeout_js
      assert js.include?("window.location.href = '/timeout'")
      assert js.include?("request.open('GET', '/active', true)")
      assert js.include?("setTimeout(PeriodicalQuery, (60 * 1000))")
    end

    it "uses custom frequency when given" do
      assert_match %r{120}, subject.auto_session_timeout_js(frequency: 120)
    end

    it "uses 60 when custom frequency is nil" do
      assert_match %r{60}, subject.auto_session_timeout_js(frequency: nil)
    end

    it "accepts attributes" do
      assert_match %r{data-turbolinks-eval="false"}, subject.auto_session_timeout_js(attributes: { 'data-turbolinks-eval': 'false' })
    end

    it "uses default timeout_path when not provided" do
      js = subject.auto_session_timeout_js
      assert js.include?("window.location.href = '/timeout'")
    end

    it "uses custom timeout_path when provided" do
      js = subject.auto_session_timeout_js(timeout_path: '/custom_timeout?param=value')
      assert js.include?("window.location.href = '/custom_timeout?param=value'")
      refute js.include?("window.location.href = '/timeout'")
    end

    it "uses custom timeout_path with multiple query params" do
      js = subject.auto_session_timeout_js(timeout_path: '/timeout?login_source=web&customer=123&location=home')
      assert js.include?("window.location.href = '/timeout?login_source=web&customer=123&location=home'")
    end

    it "clears existing timeout to prevent duplicates with Turbolinks/Turbo" do
      js = subject.auto_session_timeout_js
      assert js.include?("clearTimeout(window.autoSessionTimeoutId)")
      assert js.include?("window.autoSessionTimeoutId = setTimeout(PeriodicalQuery")
    end
  end

end
