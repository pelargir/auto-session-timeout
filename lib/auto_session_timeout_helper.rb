module AutoSessionTimeoutHelper
  def auto_session_timeout_js(options={})
    frequency = options[:frequency] || 60
    attributes = options[:attributes] || {}
    timeout_url = options[:timeout_path] || timeout_path
    code = <<JS
if (typeof(window.autoSessionTimeoutId) !== 'undefined') {
  clearTimeout(window.autoSessionTimeoutId);
}
function PeriodicalQuery() {
  var request = new XMLHttpRequest();
  request.onload = function (event) {
    var status = event.target.status;
    var response = event.target.response;
    if (status === 200 && (response === false || response === 'false' || response === null)) {
      window.location.href = '#{timeout_url}';
    }
  };
  request.open('GET', '#{active_path}', true);
  request.responseType = 'json';
  request.send();
  window.autoSessionTimeoutId = setTimeout(PeriodicalQuery, (#{frequency} * 1000));
}
window.autoSessionTimeoutId = setTimeout(PeriodicalQuery, (#{frequency} * 1000));
JS
    javascript_tag(code, attributes)
  end
end

ActiveSupport.on_load(:action_view) do
  include AutoSessionTimeoutHelper
end
