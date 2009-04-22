module AutoSessionTimeoutHelper
  def auto_session_timeout_js
    code = <<JS
new Ajax.PeriodicalUpdater('', '/active', {frequency:60, method:'get', onSuccess: function(e) {
	if ($('active_session').innerHTML == 'true' && e.responseText == 'false') {
		alert('Your session has timed out.');
		window.location.href = '/logout';
	}
}});
JS
    html = content_tag(:div, :id => "active_session") { logged_in? }
    html << "\n" << javascript_tag(code)
    html
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper