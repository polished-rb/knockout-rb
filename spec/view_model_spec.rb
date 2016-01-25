require 'spec_helper'

#### ViewModel Classes ####
class TestBindings < Knockout::ViewModel
  attr_accessor :text_var

  bind_id       "test-bindings"
  bind_var      :text_var
  bind_accessor :html_var

  def initialize
    super
    self.text_var = "Var 123"
  end
end

class TestSubviewBindings < Knockout::ViewModel
  bind_id         "test-subview-bindings"
  bind_accessor   :somesubview, :somesubview2

  def initialize
    super
    
    self.somesubview = TestSubView.new_with_parent(self, 100)
    self.somesubview2 = TestSubView.new_with_parent(self, 200)
  end
end

class TestSubView < Knockout::ViewModel
  bind_accessor   :somevar
    
  def initialize(additional_number)
    super
        
    self.somevar = 12345 + additional_number
  end
  
  # multiply the incoming value by 100 and make sure that's reflected in the HTML output
  def somevar=(val)
    @somevar = val * 100
  end
end

class TestCollection < Knockout::ViewModel
  bind_id "test-collection"
  bind_collection :items, class_name: 'TestCollectionItem'
  
  def initialize(data)
    super
    self.items.concat(data)
  end
end

class TestCollectionItem < Knockout::ViewModel
  bind_accessor   :title
end

#### Test Routines ####
describe 'knockout bindings' do
  before(:all) do
    @view_html = '<div id="bindtest1" data-bind-id="test-bindings" style="display:none"><span class="text-var" data-bind="text: text_var">_</span><span class="html-var" data-bind="html: html_var"></span></div>'
    
    Element.find('body') << @view_html
    @view_model = TestBindings.new
  end
  
  it 'should bind a string var' do
    var_element = Element.find('#bindtest1 > span.text-var')
    expect(var_element.text).to eq('Var 123')
    @view_model.text_var = "Var 456"
    expect(var_element.text).to eq('Var 456')
  end
  
  it 'should bind an HTML var' do
    var_element = Element.find('#bindtest1 > span.html-var')
    @view_model.html_var = "<strong><em>This is very strong!</em></strong>"
    expect(var_element.find('strong > em').text).to eq('This is very strong!')
  end
  
  it 'should bind a subview and support data manipulation on setters' do
    subview_html = '<div id="bindtest2" data-bind-id="test-subview-bindings" style="display:none"><div data-bind="with: somesubview"><span class="text-var" data-bind="text: somevar">_</span></div><div data-bind="with: somesubview2"><span class="text-var" data-bind="text: somevar">_</span></div></div>'
    Element.find('body') << subview_html
    view_model = TestSubviewBindings.new
    expect(Element.find('#bindtest2 > div:eq(0) > span.text-var').text).to eq('1244500')
    view_model.somesubview.somevar = 67890
    expect(Element.find('#bindtest2 > div:eq(0) > span.text-var').text).to eq('6789000')
    
    # at one point more than one subview was buggy. make sure this is working!!!
    expect(Element.find('#bindtest2 > div:eq(1) > span.text-var').text).to eq('1254500')
  end
end

describe 'bindings with view collections' do
  it 'should bind a view with view collection objects' do
    collection_html = '<div id="bindcoltest" data-bind-id="test-collection" style="display:none"><ul data-bind="foreach: items"><li><span data-bind="text: title">_</span></li></ul></div>'
    Element.find('body') << collection_html
    
    load_array = [{title: 'Name 1'}, {title: 'Name 2'}]
    
    view_model = TestCollection.new(load_array)
    
    expect(Element.find('#bindcoltest > ul > li:eq(0) > span').text).to eq('Name 1')
    expect(Element.find('#bindcoltest > ul > li:eq(1) > span').text).to eq('Name 2')
    
    view_model.items[0].title = "Name 1.0"
    
    expect(Element.find('#bindcoltest > ul > li:eq(0) > span').text).to eq('Name 1.0')
    
    view_model.items << {title: "Name 3"}
    
    expect(Element.find('#bindcoltest > ul > li:eq(2) > span').text).to eq('Name 3')
    
    expect(view_model.items[0].parent_view).to eq(view_model)
    
    view_model.items << TestCollectionItem.new.tap{|item| item.parent_view = view_model; item.title = "Name 4" }
    
    expect(Element.find('#bindcoltest > ul > li:eq(3) > span').text).to eq('Name 4')    
  end
end