require 'opal/knockout/helpers/knockout_helpers'
module OpalKnockout
  class Railtie < Rails::Railtie
    initializer "opal_knockout.knockout_helpers" do
      ActiveSupport.on_load( :action_view ){ include OpalKnockout::KnockoutHelpers }
    end
  end
end