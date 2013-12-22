class DirectionStop < ActiveRecord::Base

  belongs_to :direction
  belongs_to :stop

  def self.refresh(direction, direction_stops)
    Stop.where(tag: direction_stops.map{ |e| e["tag"] }).each do |stop|
      DirectionStop.where(direction_id: direction.id, stop_id: stop.id).first_or_create
    end
  end

  def route
    direction.bus_route
  end
end
