require File.dirname(__FILE__) + '/test_helper'

describe AutoSessionTimeoutHelper do

  subject { Class.new(ActionView::Base).new }

  describe "#auto_session_timeout_js" do
    it "returns correct JS" do
      assert_equal "<script type=\"text/javascript\">
//<![CDATA[
if (typeof(Ajax) != 'undefined') {
  new Ajax.PeriodicalUpdater('', '/active', {frequency:60, method:'get', onSuccess: function(e) {
    if (e.responseText == 'false') window.location.href = '/timeout';
  }});
}else if(typeof(jQuery) != 'undefined'){
  function PeriodicalQuery() {
    $.ajax({
      url: '/active',
      success: function(data) {
        if(data == 'false'){
          window.location.href = '/timeout';
        }
      }
    });
    setTimeout(PeriodicalQuery, (60 * 1000));
  }
  setTimeout(PeriodicalQuery, (60 * 1000));
} else {
  $.PeriodicalUpdater('/active', {minTimeout:60000, multiplier:0, method:'get', verbose:2}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false')
      window.location.href = '/timeout';
  });
}

//]]>
</script>", subject.auto_session_timeout_js
    end

    it "uses custom frequency when given" do
      assert_match /frequency:120/, subject.auto_session_timeout_js(frequency: 120)
    end

    it "uses 60 when custom frequency is nil" do
      assert_match /frequency:60/, subject.auto_session_timeout_js(frequency: nil)
    end
  end

end
