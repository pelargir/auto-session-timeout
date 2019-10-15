require File.dirname(__FILE__) + '/test_helper'

describe AutoSessionTimeoutHelper do

  class ActionView::Base
    def timeout_path
      '/timeout'
    end
    
    def active_path
      '/active'
    end
  end

  subject { ActionView::Base.new }

  describe "#auto_session_timeout_js" do
    it "returns correct JS" do
      assert_equal "<script type=\"text/javascript\">
//<![CDATA[
function PeriodicalQuery() {
  var request = new XMLHttpRequest();
  request.onload = function (event) {
    var status = event.target.status;
    var response = event.target.response;
    if (status === 200 && (response === false || response === 'false' || response === null)) {
      window.location.href = '/timeout';
    }
  };
  request.open('GET', '/active', true);
  request.responseType = 'json';
  request.send();
  setTimeout(PeriodicalQuery, (60 * 1000));
}
setTimeout(PeriodicalQuery, (60 * 1000));

//]]>
</script>", subject.auto_session_timeout_js
    end

    it "uses custom frequency when given" do
      assert_match /120/, subject.auto_session_timeout_js(frequency: 120)
    end

    it "uses 60 when custom frequency is nil" do
      assert_match /60/, subject.auto_session_timeout_js(frequency: nil)
    end

    it "accepts attributes" do
      assert_match /data-turbolinks-eval="false"/, subject.auto_session_timeout_js(attributes: { 'data-turbolinks-eval': 'false' })
    end
  end

end
