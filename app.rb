require 'sinatra'
require 'sinatra/activerecord'
require './models/direction'
require './models/direction_stop'
require './models/bus_route'
require './models/stop'
require './muni_api'


get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/stops' do
  stops = Stop.nearby_stops(params[:lat].to_f, params[:lng].to_f)
  results = []
  stops.each do |stop|
    result = {
        title: stop.title,
        lat: stop.lat,
        lng: stop.lng,
        stopId: stop.stop_id,
        stopTag: stop.tag,
    }
    result[:routes] = DirectionStop.
        where(stop_id: stop.id).includes(direction: [:bus_route] ).
        map{ |e| {routeTag: e.route.tag} }
    results.push result
  end
  results.to_json
end