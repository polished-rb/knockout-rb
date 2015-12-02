[Knockout.js](http://knockoutjs.com) is a popular MVVM (Model-View-ViewModel) library for dynamic front-end web development. Associate DOM elements with model data using a concise, readable syntax. When your data model's state changes, your UI updates automatically.

[Opal](http://opalrb.org) is a Ruby to JavaScript Compiler. It is source-to-source, making it fast as a runtime. Opal includes a compiler (which can be run in any browser), a corelib and runtime implementation. The corelib/runtime is also very small.

The **[Opal-Knockout](https://github.com/jaredcwhite/opal-knockout)** gem brings these two technologies together, allowing you to write new View Models with simple Ruby code to handle dynamic data, event handling, and nested compotent composition. All the Knockout connections are managed for you, facilitating an elegant way to load, edit, and save data that updates the HTML DOM in real-time.

Here's an example of a simple View Model:

{% highlight ruby %}
class UsersView < Knockout::ViewModel
  bind_id         "users-list"
  bind_collection :users, class_name: 'UserView'
  bind_accessor   :active_users_count
  bind_event      :new_user
  
  def new_user
    # handle the "New User" button click
    
    self.active_users_count += 1
  end
end
{% endhighlight %}

To learn more about how this works and to get started using Opal-Knockout in your own project, read the [Getting Started tutorial](/opal-knockout/getting-started/). For further in-depth documentation, visit the [Documentation section](/opal-knockout/docs/).

Interested in contributing, or need to raise an issue? The {% include icon-github.html username="jaredcwhite" %} /
[opal-knockout](https://github.com/jaredcwhite/opal-knockout) repo on GitHub is the place to start!