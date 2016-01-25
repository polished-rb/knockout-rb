# Polished: Knockout

An [Opal (Ruby-to-JS)](http://opalrb.org) library for creating view models that use Knockout.js for dynamic HTML updates and event handling.

## Installation

Add this line to your application's Gemfile:

    gem 'polished-knockout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polished-knockout

## Getting Started

Read the [Getting Started](http://polished-rb.github.io/knockout-rb/getting-started/) tutorial to see how easy it is to build view models and load in JSON data. Sneak peak:

```ruby
class UserView < Knockout::ViewModel
  bind_accessor   :first_name, :last_name, :age, :user_types
  bind_collection :favorite_foods, class_name: 'FavoriteFoodView'
end
```

For more in-depth documentation, visit the [Documentation](http://polished-rb.github.io/knockout-rb/docs/) page.

## Contributing

1. Fork it ( http://github.com/polished-rb/knockout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

Simply run `rackup` at your command line when you're in the project folder. It will load a webserver at port 9292. Then just go to your browser and access `http://localhost:9292`. You should get the full rspec suite runner output. (And hopefully, everything's green!)