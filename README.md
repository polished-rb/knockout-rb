# Polished: Knockout

An [Opal (Ruby-to-JS)](http://opalrb.org) wrapper for creating view models that use Knockout.js for dynamic HTML updates and event handling.

## Installation

_NOTE! This project is still in its infancy and not yet on RubyGems. Once it's initially released, this will work:_

Add this line to your application's Gemfile:

    gem 'polished-knockout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polished-knockout

## Usage

Documentation on the way. An example:

### Given JSON like this:

```json
[
  {
    "first_name": "Jasmine",
    "last_name": "Kitty",
    "age": 6,
    "user_types": ["Female", "Cat"],
    "favorite_foods": [
      {
        "name": "Fish",
        "origin": "Ocean"
      },
      {
        "name": "Kibble",
        "origin": "Pet Store"
      }
    ]
  }
]
```

### And some HTML markup like this:

```html
<div data-bind-id="test-users">
  <ul data-bind="foreach: users">
    <li>
      <span data-bind="text: first_name">_</span>
        loves
      <span data-bind="foreach: favorite_foods">
        <span data-bind="text: name">_</span>
          from
        <span data-bind="text: origin">_</span>
      </span>
    </li>
  </ul>
</div>
```

### And your View Models like this:

```ruby
class UsersView < Knockout::ViewModel
  bind_id         "test-users"
  bind_collection :users, class_name: 'UserView'
end

class UserView < Knockout::ViewModel
  bind_accessor   :first_name, :last_name, :age, :user_types
  bind_collection :favorite_foods, class_name: 'FavoriteFoodView'
end

class FavoriteFoodView < Knockout::ViewModel
  bind_accessor   :name
  bind_var        :origin
  
  def origin=(val)
    @origin = val
  end
  def origin
    @origin ? @origin.upcase : ""
  end
end
```

### Rendering the Knockout model is easy!

Just instantiate your top-level model, load the JSON into the collection, and knockout will use all of the bindings to update the DOM and render the users. Live updates are a cinch.

```ruby
users_view = UsersView.new
		
HTTP.get("/users.json").then do |response|
  users_view.users.concat(response.json)
end

# updates the DOM in real-time
users_view.users[0].favorite_foods[0].name = "Tuna Fish"

# Calculated values aren't a problem
puts users_view.users[0].favorite_foods[1].origin # output is "PET STORE"
```


## Contributing

1. Fork it ( http://github.com/polished-rb/knockout/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Testing

Simply run `rackup` at your command line when you're in the project folder. It will load a webserver at port 9292. Then just go to your browser and access `http://localhost:9292`. You should get the full rspec suite runner output. (And hopefully, everything's green!)