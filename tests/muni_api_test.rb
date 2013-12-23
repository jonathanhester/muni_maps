ENV['RACK_ENV'] = 'test'

require '../app'
require 'test/unit'
require 'mocha/setup'

class MuniApiTest < Test::Unit::TestCase

  def clear_db
    BusRoute.delete_all
    Direction.delete_all
    DirectionStop.delete_all
    Stop.delete_all
  end

  def setup_muni_api_mock
    routes = [{tag: "6", title: "6 line"}.with_indifferent_access]
    stops = {
        stop: [{
                   tag: "3819",
                   title: "Haight/Baker",
                   shortTitle: nil,
                   lat: 37.77129,
                   lon: -122.4373699,
                   stopId: 1
               }.with_indifferent_access],
        direction: [{
                        stop: [{"tag" => "3819"}],
                        tag: "24_OB3",
                        title: "Outbound to the Bayview District",
                        name: "Outbound",
                    }.with_indifferent_access]
    }.with_indifferent_access
    MuniApi.expects(:fetch_routes).returns(routes)
    MuniApi.expects(:fetch_stops).returns(stops)
  end

  def test_refresh_data
    clear_db

    setup_muni_api_mock

    MuniApi.refresh_data

    route = BusRoute.first
    assert_equal route.tag, "6"
    assert_equal route.title, "6 line"

    direction = Direction.first
    assert_equal direction.tag, "24_OB3"
    assert_equal direction.title, "Outbound to the Bayview District"
    assert_equal direction.name, "Outbound"

    stop = Stop.first
    assert_equal stop.tag, "3819"
    assert_equal stop.title, "Haight/Baker"
    assert_equal stop.lat, 37.77129

    direction_stop = DirectionStop.first
    assert_equal direction_stop.direction_id, direction.id
    assert_equal direction_stop.stop_id, stop.id
  end

  def test_nearby_stops
    #just run the refresh data to load the db with our "fixtures"
    clear_db
    setup_muni_api_mock
    MuniApi.refresh_data

    stop = Stop.nearby_stops(37.77129 - 0.0001, -122.4373699 + 0.0001).first
    assert_equal stop.tag, "3819"
  end

end