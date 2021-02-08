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
  end

end
