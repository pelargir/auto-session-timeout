module AutoSessionTimeoutHelper
  def auto_session_timeout_js
    code = <<JS
new Ajax.PeriodicalUpdater('', '/active', {frequency:60, method:'get', onSuccess: function(e) {
	if (e.responseText == 'false') window.location.href = '/timeout';
}});
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper