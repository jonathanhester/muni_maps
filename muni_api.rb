require 'httparty'

class MuniApi

  def self.fetch_routes
    url = "http://webservices.nextbus.com/service/publicXMLFeed"
    response = HTTParty.get(url, query: { command: "routeList", a: "sf-muni" })
    return response.parsed_response["body"]["route"]
  end

  def self.fetch_stops(routeTag)
    url = "http://webservices.nextbus.com/service/publicXMLFeed"
    response = HTTParty.get(url, query: { command: "routeConfig", a: "sf-muni", r: routeTag })
    return response.parsed_response["body"]["route"]
  end

  def self.refresh_data(options = {})
    routes = MuniApi.fetch_routes
    BusRoute.refresh(routes)

    BusRoute.find_each do |route|
      next if options && options[:start_id] && route.id < options[:start_id]
      route_details = MuniApi.fetch_stops(route.tag)
      Stop.refresh(route_details["stop"])
      Direction.refresh(route, route_details["direction"])
    end

  end

end