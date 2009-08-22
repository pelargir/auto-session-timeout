Gem::Specification.new do |s|
  s.name     = "auto-session-timeout"
  s.version  = "0.5"
  s.date     = "2009-04-22"
  s.summary  = "Provides automatic session timeout in a Rails application."
  s.email    = "pelargir@gmail.com"
  s.homepage = "http://github.com/pelargir/auto-session-timeout"
  s.description = "Adds several handy expectations for testing ActiveRecord model validations."
  s.has_rdoc = true
  s.authors  = ["Matthew Bass"]
  s.files    = [
    "auto_session_timeout.gemspec",
    "CHANGELOG",
    "init.rb",
    "lib/auto_session_timeout.rb",
		"lib/auto_session_timeout_helper.rb",
    "MIT-LICENSE",
    "Rakefile",
		"README",
		"test/auto_session_timeout_test.rb",
		"test/test_helper.rb"
		]
  s.rdoc_options = ["--main", "README"]
  s.extra_rdoc_files = ["README"]
end