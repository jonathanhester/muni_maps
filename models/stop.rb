class Stop < ActiveRecord::Base

  has_many :directions, through: :direction_stops

  def self.nearby_stops(lat, lng)
    lat_diff = 0.004
    lng_diff = 0.006
    Stop.where("lat < ? and lat > ? and lng < ? and lng > ?",
               (lat + lat_diff).to_s,
               (lat - lat_diff).to_s,
               (lng + lng_diff).to_s,
               (lng - lng_diff).to_s
    )

  end

  def self.refresh(stops)
    #HTTParty parses multiple xml nodes of the same name into an array
    #but if there's only 1, it's just the hash
    stops = [stops] unless stops.is_a? Array
    stops.each do |stop|
      tag = stop["tag"]
      title = stop["title"]
      short_title = stop["shortTitle"]
      lat = stop["lat"]
      lng = stop["lon"]
      stop_id = stop["stopId"]
      Stop.where(tag: tag).first_or_create.update_attributes(
          title: title,
          short_title: short_title,
          lat: lat,
          lng: lng,
          stop_id: stop_id,
      )
    end
  end
end
