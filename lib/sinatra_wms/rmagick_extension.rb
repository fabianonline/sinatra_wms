require 'RMagick'

module Magick
	class Draw
		WMS_FUNCTIONS_SINGLE = %w(color matte point text bigpoint)
		WMS_FUNCTIONS_DOUBLE = %w(circle ellipse line rectangle roundrectangle)
		
		def method_missing(sym, *args, &block)
			puts sym
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
		
		def wms_settings=(hash)
			hash[:min_sin_y] = 2*Math.asin(hash[:bbox][0][0] / 90.0) / Math::PI
			hash[:max_sin_y] = 2*Math.asin(hash[:bbox][1][0] / 90.0) / Math::PI
			
			hash[:factor_x] = hash[:width] / (hash[:bbox][1][1] - hash[:bbox][0][1])
			@wms_settings = hash
		end

		def bigpoint(x, y)
			rectangle(x-1, y-1, x+1, y+1)
		end
		
		def respond_to?(sym)
			result = sym.to_s.match /^([a-z0-9_]+)_(?:wgs84)$/
			(result && super(result[1]) && @wms_settings) || super(sym)
		end
		
		private
		def latlon_to_pixels(x, y)
			raise "wms_settings is missing values" unless [:bbox, :factor_x, :min_sin_y, :max_sin_y, :height].all?{|v| @wms_settings.has_key?(v)}
			x = ((x - @wms_settings[:bbox][0][1]) * @wms_settings[:factor_x]).round
			y = (1 - (((2 * Math.asin(y / 90.0) / Math::PI) - @wms_settings[:min_sin_y]) / (@wms_settings[:max_sin_y] - @wms_settings[:min_sin_y]))) * @wms_settings[:height]
			return [x, y]
		end
	end
end
