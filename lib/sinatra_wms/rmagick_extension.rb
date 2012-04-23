require 'RMagick'

##
# Monkeypatching RMagick to add some methods to +Magick::Draw+.
module Magick
	class Draw
		##
		# Which methods with one coordinates as parameter to add +_wgs84+ method to
		WMS_FUNCTIONS_SINGLE = %w(color matte point text bigpoint)
		##
		# Which methods with two coordinates as parameter to add +_wgs84+ method to
		WMS_FUNCTIONS_DOUBLE = %w(circle ellipse line rectangle roundrectangle)
		
		##
		# We use method_missing to catch calls to the +_wgs84+ methods.
		def method_missing(sym, *args, &block)
			result = sym.to_s.match /^([a-z0-9_]+)_(?:wgs84)$/
			if result && respond_to?(result[1]) && @wms_settings
				if WMS_FUNCTIONS_SINGLE.include?(result[1])
					args[0], args[1] = latlon_to_pixels(args[0], args[1])
				elsif WMS_FUNCTIONS_DOUBLE.include?(result[1])
					args[0], args[1] = latlon_to_pixels(args[0], args[1])
					args[2], args[3] = latlon_to_pixels(args[2], args[3])
				end
				send(result[1], *args, &block)
			else
				super(sym, *args, &block)
			end
		end
		
		##
		# This method gets the data from +SinatraExtension+ and does some calculations
		# to have values prepared when they're needed.
		def wms_settings=(hash)
			hash[:min_sin_y] = Math::asinh(Math::tan(hash[:bbox][0][0] / 180.0 * Math::PI)) * 6378137.0
			hash[:max_sin_y] = Math::asinh(Math::tan(hash[:bbox][1][0] / 180.0 * Math::PI)) * 6378137.0
			hash[:diff_y] = hash[:max_sin_y] - hash[:min_sin_y]
			hash[:factor_x] = hash[:width] / (hash[:bbox][1][1] - hash[:bbox][0][1])
			@wms_settings = hash
		end
		
		##
		# The same as +point+, but draws a "big point" with 3 pixels width and height.
		def bigpoint(x, y)
			rectangle(x-1, y-1, x+1, y+1)
		end
		
		##
		# See +method_missing+
		def respond_to?(sym)
			result = sym.to_s.match /^([a-z0-9_]+)_(?:wgs84)$/
			(result && super(result[1]) && @wms_settings) || super(sym)
		end
		
		private
		##
		# Converts WGS84 coordinates to pixel values.
		# Gets called via +method_missing+, whenever one of the +*_wgs84* methods is used.
		def latlon_to_pixels(x, y)
			raise "wms_settings is missing values" unless [:bbox, :factor_x, :min_sin_y, :max_sin_y, :height].all?{|v| @wms_settings.has_key?(v)}
			x = ((x - @wms_settings[:bbox][0][1]) * @wms_settings[:factor_x]).round
			y = (1 - (((Math::asinh(Math::tan(y / 180.0 * Math::PI)) * 6378137.0) - @wms_settings[:min_sin_y]) / @wms_settings[:diff_y])) * @wms_settings[:height]
			return [x, y]
		end
	end
end
