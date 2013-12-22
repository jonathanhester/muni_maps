class Direction < ActiveRecord::Base

  belongs_to :bus_route

  def self.refresh(route, directions)
    #HTTParty parses multiple xml nodes of the same name into an array
    #but if there's only 1, it's just the hash
    directions = [directions] unless directions.is_a? Array
    directions.each do |direction|
      tag = direction["tag"]
      title = direction["title"]
      name = direction["name"]
      route_direction = Direction.where(tag: tag).first_or_create
      route_direction.update_attributes(title: title, name: name, bus_route_id: route.id)
      DirectionStop.refresh(route_direction, direction["stop"])
    end
  end
end
