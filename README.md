[![Build Status](https://travis-ci.com/pelargir/auto-session-timeout.svg?branch=master)](https://travis-ci.com/pelargir/auto-session-timeout)

# Auto::Session::Timeout

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

```
$ bundle
```

Or install it yourself as:

```
$ gem install auto-session-timeout
```

## Usage

After installing, tell your application controller to use auto timeout:

```ruby
class ApplicationController < ActionController::Base
  auto_session_timeout 1.hour
end
```

This will use a global timeout of 1 hour. The gem assumes your authentication
provider has a `#current_user` method that returns the currently logged in user.

If you want to specify a  custom timeout value per user, don't pass a value to
the controller as shown above. Instead,  override `#auto_timeout` in your
`#current_user` model. This is  typically the `User` class:

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
get "active",  to: "sessions#active"
get "timeout", to: "sessions#timeout"
```

You're done! Enjoy watching your sessions automatically timeout.

## Using with Devise

When using Devise for authentication you will need to add a scoped
sessions controller and call the timeout actions helper there.
For example:

```ruby
class Users::SessionsController < Devise::SessionsController
  auto_session_timeout_actions
end
```

In your routes.rb file you will need to declare your scoped controller
and declare the timeout actions inside the same Devise scope:

```ruby
Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: "users/sessions" }
  
  devise_scope :user do
    get "active", to: "users/sessions#active"
    get "timeout", to: "users/sessions#timeout"
  end
end
```

You can use Devise's `#user_signed_in?` method when you call the JS helper
method in your view:

```erb
<body>
  <% if user_signed_in? %>
    <%= auto_session_timeout_js %>
  <% end %>
</body>
```

## Optional Configuration

By default, the JavaScript code checks the server every 60 seconds for
active sessions. If you prefer that it check more frequently, pass a
frequency attribute to the helper method. The frequency is given in
seconds. The following example checks the server every 15 seconds:

```erb
<body>
  <% if current_user %>
    <%= auto_session_timeout_js frequency: 15 %>
  <% end %>
</body>
```

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
