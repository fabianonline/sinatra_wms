require "sinatra_wms/version"
require "sinatra_wms/sinatra_extension"
require "sinatra_wms/rmagick_extension"

module SinatraWMS
	def self.merc_to_latlon(x, y)
		lon = (x / 6378137.0) / Math::PI * 180
		lat = Math::atan(Math::sinh(y / 6378137.0)) / Math::PI * 180
		return [lat, lon]
	end

	def self.deg_sin(x)
		Math.sin(x * Math::PI / 180)
	end
end
