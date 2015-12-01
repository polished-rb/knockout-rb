require 'bundler'
Bundler.require

require 'opal-rspec'
Opal.append_path File.expand_path('../spec', __FILE__)

require 'opal/jquery'

run Opal::Server.new { |s|
  s.main = 'opal/rspec/sprockets_runner'
  s.append_path 'spec'
  s.debug = false
  s.index_path = 'spec/knockout/index.html.erb'
}