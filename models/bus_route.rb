class BusRoute < ActiveRecord::Base
  has_many :directions

  def self.refresh(routes)
    routes.each do |route|
      tag = route["tag"]
      title = route["title"]
      BusRoute.where(tag: tag).first_or_create.
          update_attributes(title: title)
    end

  end
end