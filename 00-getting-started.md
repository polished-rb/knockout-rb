---
layout: page
title: Getting Started
permalink: /getting-started/
---

First, you'll need to add the Polished: Knockout gem to your project (Rails or otherwise), typically by adding a line to your application's Gemfile:

    gem 'polished-knockout'

The gem does not come with a copy of the actual Knockout.js file, so you'll need to include that in your layout file. For instance, using Knockout's CDN:

    <script src="https://cdnjs.cloudflare.com/ajax/libs/knockout/3.4.0/knockout-min.js"></script>
    
It's beyond the scope of this tutorial to explain how Knockout.js' HTML bindings syntax works, but suffice it to say, it can enable some pretty powerful dynamic behavior which you'll see in a moment.

You also need to make sure the `opal-jquery` gem is loaded as well.


### Add HTML markup to your project

Let's say your app's target audience is cats, so you'll want each cat to be able to save their name, age, and favorite foods and where they come from. To list out each cat, you could write some simple markup like this:

```html
<div data-bind-id="test-users">
  <ul data-bind="foreach: users">
    <li>
      <span data-bind="text: first_name">_</span>
        (age <span data-bind="text: age">_</span>) loves
      <span data-bind="foreach: favorite_foods">
        <span data-bind="text: name">_</span>
          from
        <span data-bind="text: origin">_</span>
      </span>
    </li>
  </ul>
</div>
```

The `data-bind-id` attribute of the top-level div is a special binding used by the **Knockout** gem to allow a hierarchy of view models to be attached to the HTML DOM automatically. The rest of the bindings are all standard Knockout.js syntax.

Notice there are a couple of `foreach` loops here in the HTML—the Ruby view models you'll write map these kinds of loops to collections using your own custom classes. It's pretty slick.


### Time to write the view models

Let's review briefly how Knockout.js enables dynamic updates. The way you write a KO view model in Javascript, in its most basic form, is this:

```javascript
var myViewModel = {
    personName: ko.observable('Bob'),
    personAge: ko.observable(123)
};
```

This creates an object with _observable_ properties—that is, you can update them and KO observes the change and updates the HTML DOM accordingly. Or, in reverse, something in the DOM changes (like a form element being updated by the user), and KO observes that change and updates the model property. For example:

```javascript
myViewModel.personName(); // will return 'Bob'
myViewModel.personName('Mary'); // updates the value and thus the DOM to 'Mary'
```

With the **Knockout** gem, the way you declare observables is quite simple and similar to how you declare accessor variables in Ruby normally:

```ruby
class PersonView < Knockout::ViewModel
  bind_accessor :person_name, :person_age
end
```

(Being this is Ruby, it's preferable to use underscore naming, aka `person_name`, etc.) To read or write those accessors (properties), it's just plain ol' Ruby:

```ruby
person_view = PersonView.new
person_view.person_name = 'Bob'
person_view.person_name # returns 'Bob'
```

Under the hood, write accessors are wrapped in special observer methods so that any setting of the property updates the Knockout.js object being stored and thus updates the HTML DOM.

So, getting back to our list of cat users, let's write some view models to connect to the HTML markup from the previous section:

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

What's that `bind_var` doing there in `FavoriteFoodView`? We'll get to that in a minute.

Let's also save a file/endpoint in your project called `users.json` and define a sample cat in JSON:

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

### Rendering the Knockout models is easy!

To get things going, all you need to do is instantiate your top-level model (in this case `UsersView`). You'll then load the JSON into the `users` collection, and Knockout.js will use all of the bindings to update the DOM and render the users. And subsequent live updates are a cinch.

Create an Opal code file that will load with the page (if you need help here, such as for a Rails project, see the [opal-rails gem documentation](https://github.com/opal/opal-rails#readme)). Here's an example:

```ruby
# Instantiate the UsersView top-level model
users_view = UsersView.new
		
# Ajax call to server to retrieve the JSON
HTTP.get("/users.json").then do |response|
  # The concat array method adds the record(s) to the users collection
  users_view.users.concat(response.json)
end
```

At this point, in your browser you should see the **Jasmine Kitty** record listed in the HTML. You can continue to tweak the DOM with live updates, for example:

```ruby
users_view.users[0].favorite_foods[0].name = "Tuna Fish"

# Calculated values work just fine
puts users_view.users[0].favorite_foods[1].origin # output is "PET STORE"
```

Remember before when the `FavoriteFoodView` had a curious `bind_var` method being used to set up `origin` rather than `bind_accessor`? You can use `bind_var` if you want to write your own custom accessor methods, and those methods (just like with default accessors) are wrapped in an observable method that's then handled by Knockout.js. Now I don't know why you'd want to transform food origins to be all caps (aka the `@origin.upcase` code you saw in the view model), but that's just an example of what's possible. Knockout.js calls these "computed observables".

### Wait, what about events?

One of the nicest things about Knockout.js is how easy it makes handling events. Let's say you want to be able to click on the origin of a cat's favorite food to learn more about that location. Simple! We'll update the HTML markup first:

```html
      <span data-bind="foreach: favorite_foods">
        <span data-bind="text: name">_</span>
          from
        <span data-bind="text: origin, click: show_origin">_</span>
      </span>
```

and to the `FavoriteFoodView` view model, we'll add an event handler:

```ruby
  def show_origin(event)
    puts event.page_x
    alert "You clicked #{origin}!"
    # do_some_code_to_load_origin_data
    # etc.
  end
```

The **knockout** gem has a dependency on jQuery (via the `opal-jquery` gem), so in this example the `event` variable is an instance of the `Event` class defined by `opal-jquery`.

You'll notice the event handler knows the correct origin that was clicked. Why? Well, in a collection, the view model class is instantiated a number of times corresponding to the entries of the collection, so just when you bind text or HTML values or whatever to each item, you bind events to each item so the event (in this case a click) is handled by the correct item.

A collection is simply an array—more specifically, a subclass of `Array` called `KnockoutArray` which connects updates of the array contents (adding items, removing items, etc.) to dynamism within Knockout.js.

### Sub Views

In addition to collections, you can set up one-to-one nested views. A collection is basically an array of views, but you might want to have a detail view under a master view for example. You can also pass initialization variables from the master view to the sub view.

```ruby
class MasterView < Knockout::ViewModel
  bind_id         "master-view"
  bind_accessor   :detail_view

  def initialize
    super
    
    self.detail_view = DetailView.new_with_parent(self, 100)
  end
end

class DetailView < Knockout::ViewModel
  bind_accessor   :somevar
    
  def initialize(incoming_number)
    super
        
    self.somevar = 12345 * incoming_number
  end
end
```

You can call the `parent_view` method from a sub view to access the master view model.

### Initialization Gotcha

If you decide to define an `initialize` method in a `Knockout::ViewModel` class, make sure you call `super` before you do anything else.

```ruby
  def initialize
    super
    self.text_var = "Var 123"
  end
```

Otherwise you'll get errant behavior.

### Problems? Questions?

We hope you have a great time using the **Polished: Knockout** gem, but if you run into any issues or have a question, let us know in [GitHub Issues](https://github.com/polished-rb/knockout-rb/issues) for the project.
