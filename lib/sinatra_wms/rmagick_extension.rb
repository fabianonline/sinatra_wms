require 'RMagick'

##
# Monkeypatching RMagick to add some methods to +Magick::Draw+.
module Magick
	class Draw
		## Wrapper for +color+, but with coordinates given in WGS84.
		def color_wgs84(x, y, *args);     args.unshift(* latlon_to_pixels(x, y)); color(*args);    end
		## Wrapper for +point+, but with coordinates given in WGS84.
		def point_wgs84(x, y, *args);     args.unshift(* latlon_to_pixels(x, y)); point(*args);    end
		## Wrapper for +matte+, but with coordinates given in WGS84.
		def matte_wgs84(x, y, *args);     args.unshift(* latlon_to_pixels(x, y)); matte(*args);    end
		## Wrapper for +text+, but with coordinates given in WGS84.
		def text_wgs84(x, y, *args);      args.unshift(* latlon_to_pixels(x, y)); text(*args);     end
		## Wrapper for +bigpoint+, but with coordinates given in WGS84.
		def bigpoint_wgs84(x, y, *args);  args.unshift(* latlon_to_pixels(x, y)); bigpoint(*args); end
		## Wrapper for +ellipse+, but with coordinates given in WGS84.
		def ellipse_wgs84(x, y, *args);   args.unshift(* latlon_to_pixels(x, y)); ellipse(*args);  end
		
		
		## Wrapper for +circle+, but with coordinates given in WGS84.
		def circle_wgs84         (x1, y1, x2, y2, *args); args.unshift(* latlon_to_pixels(x2, y2)).unshift(* latlon_to_pixels(x1, y1)); cirle(*args);          end
		## Wrapper for +line+, but with coordinates given in WGS84.
		def line_wgs84           (x1, y1, x2, y2, *args); args.unshift(* latlon_to_pixels(x2, y2)).unshift(* latlon_to_pixels(x1, y1)); line(*args);           end
		## Wrapper for +rectangle+, but with coordinates given in WGS84.
		def rectangle_wgs84      (x1, y1, x2, y2, *args); args.unshift(* latlon_to_pixels(x2, y2)).unshift(* latlon_to_pixels(x1, y1)); rectangle(*args);      end
		## Wrapper for +roundrectangle+, but with coordinates given in WGS84.
		def roundrectangle_wgs84 (x1, y1, x2, y2, *args); args.unshift(* latlon_to_pixels(x2, y2)).unshift(* latlon_to_pixels(x1, y1)); roundrectangle(*args); end
		
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
