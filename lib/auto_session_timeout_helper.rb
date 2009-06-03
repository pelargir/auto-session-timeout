module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    code = <<JS
new Ajax.PeriodicalUpdater('', '/active', {frequency:#{frequency}, method:'get', onSuccess: function(e) {
	if (e.responseText == 'false') window.location.href = '/timeout';
}});
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper