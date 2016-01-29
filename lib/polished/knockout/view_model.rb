# Knockout::ViewModel provides a simple Opal-based Ruby wrapper around
# Knockout.js, a popular front-end data-binding and events library.
#
# Run one or more of these class methods in a Knockout::ViewModel
# subclass, aka
#
# bind_var    :somevar, :anothervar
# bind_event  :clickme
#
# and then wrappers will be created for the JS model that is passed to
# Knockout
#
# You can either do attr_accessor :somevar, :anothervar or write custom
# methods in your class, or you can use the shortcut bind_accessor to set
# up bind_var and attr_accessor at once.
#
# You'll need to use bind_id on a top-level view to target an element in your
# DOM with data-bind-id:
#
# bind_id      :some-id
#
# Example HTML:
# <div data-bind-id="some-id">
#  <span data-bind="text: somevar"> </span>, <span data-bind="html: anothervar"> </span>
# </div>
#
# Methods in your class are passed a jQuery event object, for example:
#
# <a href="#" data-bind="click: clickme">Click me!</a>
#
# def clickme(event)
#   puts event.page_x
# end
#
# TODO: remove dependency on jQuery events, so for example opal-browser events
# could also be used
#
# -----
#
# Subview docs forthcoming...
#

module Knockout
  class ViewModel

    def self.bind_setup
      if @bind_defs.nil?
        @bind_defs = {
          :vars => [],
          :subviews => [],
          :collections => [],
          :events => [],
          :methods => []
        }
        attr_accessor :parent_view
      end
    end

    def self.bind_id(bind_id)
      bind_setup
      @bind_defs[:id] = bind_id
    end
    def self.bind_var(*arr)
      bind_setup
      @bind_defs[:vars] += arr
    end
    def self.bind_accessor(*arr)
      bind_setup
      @bind_defs[:vars] += arr
      attr_accessor(*arr)
    end
    def self.bind_collection(name, options=nil)
      bind_setup
      @bind_defs[:collections] << {
        varname: name,
        class_name: options.is_a?(Hash) ? options[:class_name] : nil
      }
      attr_accessor(name)
    end
    def self.bind_event(*arr)
      bind_setup
      @bind_defs[:events] += arr
    end
    def self.bind_method(*arr)
      bind_setup
      @bind_defs[:methods] += arr
    end
  
    def self.bind_defs
      @bind_defs
    end

    def initialize
      begin
        @bound_model = `{}`
        self.class.bind_defs()[:vars].each do |var_label|
          if self.send(var_label).is_a?(KnockoutArray)
            ko_arr_observable = self.send(var_label).to_n
            `self.bound_model[var_label] = ko_arr_observable`
# At some point, figure out how to make it so
# foomodel.array = ['abc', 123]
# actually just clears and adds back in stuff via the magic
# KnockoutArray stuff
#
#           define_singleton_method("#{var_label}=") do |val|
#             result = super val
#             attribute_did_change(attribute)
#             result
#           end
          else
            `self.bound_model[var_label] = ko.observable(null)`
            `var skipit = '_skip_observable_' + var_label`
            `self.bound_model[var_label].subscribe(function(newValue) {`
              `if (typeof self[skipit] == 'undefined' || self[skipit] != true) {
                self[skipit] = true`
                self.send(var_label + "=", `newValue`)
                `self[skipit] = false`
              `}`
            `});`
            self.add_observer(var_label) do |new_val|
              if new_val.is_a?(Array) or new_val.is_a?(Hash) or new_val.is_a?(ViewModel)
                new_val = new_val.to_n  # to_n converts an Opal-based object to a "native" JS object
              end
              `if (typeof self[skipit] == 'undefined' || self[skipit] != true) { `
                `self[skipit] = true`
                `self.bound_model[var_label](new_val)`
              `}`
              `self[skipit] = false`
            end
          end
        end if self.class.bind_defs()[:vars]
        
        self.class.bind_defs()[:collections].each do |collection|
          var_label = collection[:varname]
          ko_arr = KnockoutArray.new
          ko_arr.set_collection_class(collection[:class_name], self)
          self.send(var_label + '=', ko_arr)
          ko_arr_observable = self.send(var_label).to_n
          `self.bound_model[var_label] = ko_arr_observable`
        end if self.class.bind_defs()[:collections]   

        self.class.bind_defs()[:events].each do |method_label|
          `self.bound_model[method_label] = function(data, event) { return self['$handle_bind_event'](method_label, event) }`
        end if self.class.bind_defs()[:events]
    
        self.class.bind_defs()[:methods].each do |method_label|
          `self.bound_model[method_label] = function(data) { return self['$handle_bind_method'](method_label, data) }`
        end if self.class.bind_defs()[:methods]
    
        if self.class.bind_defs()[:id]
          bind_id = self.class.bind_defs()[:id]
          bind_el = `$('[data-bind-id=' + bind_id + ']')`
          `ko.applyBindings(self.bound_model, bind_el.get(0))`
          `bind_el.addClass('ko-bound')`
        end
      rescue Exception => e
        Element.find('body').add_class('ko-debug')
        raise e
      end
    end
    
    def self.new_via_collection(hash_obj, parent=nil)
      new_object = self.new
      new_object.parent_view = parent if parent
      hash_obj.each do |k,v|
        if v.is_a?(Array) and new_object.send(k).is_a?(KnockoutArray)
          ko_arr = new_object.send(k)
          ko_arr.clear
          ko_arr.concat(v)
        else
          new_object.send(k + "=", v)
        end
      end
      new_object
    end
    
    def self.new_with_parent(parent, *arr)
      new_object = self.new(*arr)
      new_object.parent_view = parent
      new_object
    end
    
    def bound_model
      @bound_model
    end
  
    def handle_bind_event(method_label, event)
      wrapped_event = Event.new(event)
      self.send(method_label, wrapped_event)
    end
    
    def handle_bind_method(method_label, data)
      self.send(method_label, data)
    end
  
    ### Override the standard to_n feature by passing along the Knockout model obj instead
    def to_n
      bound_model
    end
    
    def to_json
      `ko.toJSON(#{@bound_model})`
    end
    
    def serialize_js_data
      `ko.toJS(#{@bound_model})`
    end
  
    ### The following Ruby observer code was borrowed from Vienna::Observable
    ### https://github.com/opal/vienna
    def add_observer(attribute, &handler)
      unless observers = @attr_observers
        observers = @attr_observers = {}
      end

      unless handlers = observers[attribute]
        handlers = observers[attribute] = []
        replace_writer_for(attribute)
      end

      handlers << handler
    end

    def remove_observer(attribute, handler)
      return unless @attr_observers

      if handlers = @attr_observers[attribute]
        handlers.delete handler
      end
    end

    # Triggers observers for the given attribute. You may call this directly if
    # needed, but it is generally called automatically for you inside a
    # replaced setter method.
    def attribute_did_change(attribute)
      return unless @attr_observers

      if handlers = @attr_observers[attribute]
        new_val = __send__(attribute) if respond_to?(attribute)
        handlers.each { |h| h.call new_val }
      end
    end

    # private?
    def replace_writer_for(attribute)
      if respond_to? "#{attribute}="
        define_singleton_method("#{attribute}=") do |val|
          result = super val
          attribute_did_change(attribute)
          result
        end
      end
    end
  end 
end

# This class is used internally and you shouldn't need to initialize it
# yourself or worry too much whether an array is a standard array or a
# KnockoutArray
#
# It's essentially a wrapper around KO's observableArray
# http://knockoutjs.com/documentation/observableArrays.html
class KnockoutArray < Array
  # NOTE: this method has to be run right after a KnockoutArray is first
  # initialized
  def to_n
    array_value = super
    
    @ko_observable = `ko.observableArray(array_value)`
    
    @ko_observable
  end
  
  def to_json
    `ko.toJSON(#{@ko_observable})`
  end
  
  def serialize_js_data
    `ko.toJS(#{@ko_observable})`
  end
  
  def set_collection_class(class_name, collection_parent)
    @collection_class_name = class_name if class_name
    @collection_parent = collection_parent
  end
  
  def collection_check(obj)
    if @collection_class_name and obj.is_a?(Hash)
      Kernel.const_get(@collection_class_name).new_via_collection(obj, @collection_parent)
    else
      obj
    end
  end
  
  def concat(other)
    if Array === other
      other = other.to_a
    else
      other = Opal.coerce_to(other, Array, :to_ary).to_a
    end

    other.each do |item|
      self.send('<<', item)
    end

    self
  end
  
  def <<(obj)
    obj = collection_check(obj)
    
    ret = super(obj)
    
    `self.ko_observable.push(obj.$to_n())`
    
    ret
  end
  
  def unshift(obj)
    obj = collection_check(obj)
    
    ret = super(obj)
    
    `self.ko_observable.unshift(obj.$to_n())`
    
    ret
  end
  
  def slice!(index, length=1)
    ret = super(index, length)
    
    unless ret == nil
      `self.ko_observable.splice(index, length)`
    end
    
    ret
  end
  
  def delete_at(index)
    ret = super(index)
    
    unless ret == nil
      `self.ko_observable.splice(index, 1)`
    end
    
    ret
  end
  
  def delete(obj)
    obj_index = index(obj)
    ret = nil
    
    unless obj_index == nil
      ret = super(obj)
      `self.ko_observable.splice(obj_index, 1)`
    end
    
    ret
  end
  
  def clear()
    ret = super
    
    `self.ko_observable.removeAll()`
    
    ret
  end
end