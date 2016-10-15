module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    code = <<JS
if (typeof(Ajax) != 'undefined') {
  new Ajax.PeriodicalUpdater('', '/active', {frequency:#{frequency}, method:'get', onSuccess: function(e) {
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
    setTimeout(PeriodicalQuery, (#{frequency} * 1000));
  }
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
} else {
  $.PeriodicalUpdater('/active', {minTimeout:#{frequency * 1000}, multiplier:0, method:'get', verbose:#{verbosity}}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false')
      window.location.href = '/timeout';
  });
}
JS
    javascript_tag(code)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper