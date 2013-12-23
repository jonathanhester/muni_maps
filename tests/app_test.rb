ENV['RACK_ENV'] = 'test'

require '../app'
require 'test/unit'
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello_world
    BusRoute.delete_all
    Direction.delete_all
    DirectionStop.delete_all
    Stop.delete_all

    stop = Stop.create(tag: "3819", title: "Haight/Baker", lat: 37.77129,  lng: -122.4373699)
    route = BusRoute.create(tag: "6", title: "6 line")
    direction = route.directions.create(tag: "24_OB3", title: "Outbound to the Bayview District",
                                 name: "Outbound")
    DirectionStop.create(stop_id: stop.id, direction_id: direction.id)
    get '/stops?lat=37.77129&lng=-122.4373699'
    assert last_response.ok?
    response = JSON.parse(last_response.body)
    assert_equal 'Haight/Baker', response.first["title"]
    assert_equal '6', response.first["routes"].first["routeTag"]
  end

end