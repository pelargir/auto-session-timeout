require 'rake'
require 'rake/testtask'
require 'rdoc/task'
require 'bundler/gem_tasks'

task default: :test

Rake::TestTask.new('test') do |t|
  t.pattern = 'test/*_test.rb'
end
