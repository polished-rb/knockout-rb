require 'spec_helper'

#### ViewModel Classes ####
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

#### Test Routines ####
describe 'bindings using server data' do
  it 'should have HTTP get support' do
    HTTP.methods.include?(:get)
  end

  it 'should save an object graph' do
    uv = UserView.new_via_collection(first_name: 'Dick', last_name: 'Tracy', age: 25, user_types: ["Male", "Human"])
    
    # Get the JSON string from the object
    test_json = uv.to_json
    
    expect(test_json).to include('{"first_name":"Dick"')
    expect(test_json).to include('"user_types":["Male","Human"]')
    
      # JSON postback to server would go here :)

      
    # also make sure real JS data objects work too
    test_js_graph = uv.serialize_js_data
    
    expect(`test_js_graph.last_name`).to eq('Tracy')
  end

  async 'should bind a view with view collection from JSON' do
    collection_html = '<div id="bind-userstest" data-bind-id="test-users" style="display:none"><ul data-bind="foreach: users"><li><span data-bind="text: first_name">_</span> loves <span class="favfoods" data-bind="foreach: favorite_foods"><span data-bind="text: name">_</span> from <span data-bind="text: origin">_</span></span></li></ul></div>'
    Element.find('body') << collection_html
    
    users_view = UsersView.new
    
    req_url = "/spec/fixtures/users.json"
    HTTP.get(req_url).then do |response|
      run_async do
        users_view.users.concat(response.json)
        expect(Element.find('#bind-userstest > ul > li:eq(0) > span:eq(0)').text).to eq('Jared')
        expect(Element.find('#bind-userstest > ul > li:eq(1) > span:eq(0)').text).to eq('Jasmine')

        expect(users_view.users[0].age).to eq(33)
        
        expect(users_view.users[1].user_types[1]).to eq('Cat')
        
        expect(users_view.users[0].favorite_foods[0].origin).to eq('MEXICO')
        
        expect(Element.find('#bind-userstest > ul > li:eq(0) span.favfoods > span:eq(2)').text).to eq('Pizza')
        
        users_view.users[0].favorite_foods[1].name = "Lasagna"
        
        expect(Element.find('#bind-userstest > ul > li:eq(0) span.favfoods > span:eq(2)').text).to eq('Lasagna')
      end

    end
        
  end

end