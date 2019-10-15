# auto-session-timeout

Provides automatic session timeout in a Rails application. Very easy
to install and configure. Have you ever wanted to force your users
off your app if they go idle for a certain period of time? Many
online banking sites use this technique. If your app is used on any
kind of public computer system, this gem is a necessity.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'auto-session-timeout'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install auto-session-timeout

## Usage

After installing, tell your application controller to use auto timeout:

```ruby
class ApplicationController < ActionController::Base
  auto_session_timeout 1.hour
  ...
end
```

This will use a global timeout of 1 hour. If you want to specify a
custom timeout value per user, don't pass a value above. Instead,
override `#auto_timeout` in your `#current_user` model. This is
typically the `User` class:

```ruby
class ApplicationController < ActionController::Base
  auto_session_timeout
end

class User < ActiveRecord::Base
  def auto_timeout
    15.minutes
  end
end
```

You will also need to insert a call to the `#auto_session_timeout_js`
helper method inside the body tags in your views. The easiest way to
do this is to insert it once inside your default or application-wide
layout. Make sure you are only rendering if the user is logged in,
otherwise the gem will attempt to force non-existent sessions to
timeout, wreaking havoc:

```erb
<body>
  <% if current_user %>
    <%= auto_session_timeout_js %>
  <% end %>
</body>
```

You need to setup two actions: one to return the session status and
another that runs when the session times out. You can use the default
actions included with the gem by inserting this line in your target
controller (most likely your user or session controller):

```ruby
class SessionsController < ApplicationController
  auto_session_timeout_actions
end
```

To customize the default actions, simply override them. You can call
the `#render_session_status` and `#render_session_timeout` methods to
use the default implementation from the gem, or you can define the
actions entirely with your own custom code:

```ruby
class SessionsController < ApplicationController
  def active
   render_session_status
  end

  def timeout
    render_session_timeout
  end
end
```

In any of these cases, make sure to properly map the actions in your
routes.rb file:

```ruby
get 'active'  => 'sessions#active'
get 'timeout' => 'sessions#timeout'
```

You're done! Enjoy watching your sessions automatically timeout.

## Additional Configuration

By default, the JavaScript code checks the server every 60 seconds for
active sessions. If you prefer that it check more frequently, pass a
frequency attribute to the helper method. The frequency is given in
seconds. The following example checks the server every 15 seconds:

```erb
<html>
  <head>...</head>
  <body>
    <% if current_user %>
      <%= auto_session_timeout_js frequency: 15 %>
    <% end %>
    ...
  </body>
</html>
```

## TODO

* current_user must be defined
* using Prototype vs. jQuery
* using with Devise

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Resources

* Repository: http://github.com/pelargir/auto-session-timeout/
* Blog: http://www.matthewbass.com
* Author: Matthew Bass
