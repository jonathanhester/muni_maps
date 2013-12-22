require 'httparty'

class MuniApi

  def self.fetch_routes
    url = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeList&a=sf-muni"
    response = HTTParty.get(url)
    return response.parsed_response["body"]["route"]
  end

  def self.fetch_stops(routeTag)
    url = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=#{routeTag}"
    response = HTTParty.get(url)
    return response.parsed_response["body"]["route"]
  end

  def self.refresh_data
    routes = MuniApi.fetch_routes
    BusRoute.refresh(routes)

    BusRoute.find_each do |route|
      route_details = MuniApi.fetch_stops(route.tag)
      Stop.refresh(route_details["stop"])
      Direction.refresh(route, route_details["direction"])
    end

  end

end