module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    verbosity = options[:verbosity] || 2
    attributes = options[:attributes] || {}
    code = <<JS
if (typeof Ajax !== 'undefined') {
  new Ajax.PeriodicalUpdater('', '/active', {frequency:#{frequency}, method:'get', onSuccess: function(e) {
    if (e.responseText == 'false') window.location.href = '/timeout';
  }});
} else if (typeof jQuery !== 'undefined'){
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
} else if (typeof $ !== 'undefined' && typeof $.PeriodicalUpdater === 'function') {
  $.PeriodicalUpdater('/active', {minTimeout:#{frequency * 1000}, multiplier:0, method:'get', verbose:#{verbosity}}, function(remoteData, success) {
    if (success == 'success' && remoteData == 'false')
      window.location.href = '/timeout';
  });
} else {
  function PeriodicalQuery() {
    var request = new XMLHttpRequest();
    request.onload = function (event) {
      var status = event.target.status;
      var response = event.target.response;
      if (status === 200 && response === false) {
        window.location.href = '/timeout';
      }
    };
    request.open('GET', '/active', true);
    request.responseType = 'json';
    request.send();
    setTimeout(PeriodicalQuery, (#{frequency} * 1000));
  }
  setTimeout(PeriodicalQuery, (#{frequency} * 1000));
}
JS
    javascript_tag(code, attributes)
  end
end

ActionView::Base.send :include, AutoSessionTimeoutHelper
