if RUBY_ENGINE == 'opal'
  require 'polished/knockout/view_model'
else
  require 'opal'
  require 'polished/knockout/version'

  Opal.append_path File.expand_path('../..', __FILE__).untaint
  
  require 'polished/knockout/railtie' if defined?(Rails::Railtie)
end