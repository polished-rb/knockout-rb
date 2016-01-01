require 'polished/knockout/helpers/knockout_helpers'
module PolishedKnockout
  class Railtie < Rails::Railtie
    initializer "polished_knockout.knockout_helpers" do
      ActiveSupport.on_load( :action_view ){ include PolishedKnockout::KnockoutHelpers }
    end
  end
end