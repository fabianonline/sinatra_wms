require 'sinatra/base'
##
# +Sinatra+ is extended to contain the method +wms+, which controls all the
# WMS-relevant stuff.
module Sinatra
	module WMS
		##
		# Reacts on WMS calls
		#
		# Defines an +url+ to react on WMS calls.
		# If we get a matching request, we will do some fancy calculations to the
		# parameters given (as in "convert the bounding box from sperical mercator
		# to the well-known WGS84 projection" and so on.)
		# Also, we will prepare an image and a matching canvas which we give to the
		# given block.
		# After the block has run, we return the image to the requestee.
		def wms(url, &block)
			get url do
				headers "Content-Type" => "image/png"
				# convert the given parameters to lowercase symbols
				options = params.inject({}) {|hash, (key, value)| hash[key.to_s.downcase.to_sym] = value; hash }
				
				# interpret :width and :height as integer
				[:width, :height].each {|what| options[what] = options[what].to_i}
				
				# convert bounding box coordinates to WGS84
				bbox = options[:bbox].split(',').collect{|v| v.to_f}
				options[:bbox] = {:original => [[bbox[0], bbox[1]], [bbox[2], bbox[3]]]}
				if options[:srs]=="EPSG:900913"
					options[:bbox][:google] = options[:bbox][:original]
					options[:bbox][:wgs84] = [*SinatraWMS::merc_to_latlon(bbox[0], bbox[1])], [*SinatraWMS::merc_to_latlon(bbox[2], bbox[3])]
				else
					raise "Unexpected Projection (srs): #{options[:srs]}"
				end
				
				# calculate the current zoom level (between 0 and 17, with 0 being the while world)
				options[:zoom] = (17-((Math.log((options[:bbox][:google][1][0]-options[:bbox][:google][0][0]).abs*3.281/500) / Math.log(2)).round))
				
				# generate a transparent image, an empty canvas and set the default
				# drawing color to black
				image = Magick::Image.new(options[:width], options[:height]) { self.background_color = 'transparent' }
				gc = Magick::Draw.new
				gc.stroke("black")
				
				# The canvas needs some values for the calculations for the +*_wgs84+ methods.
				gc.wms_settings = {
					:bbox => options[:bbox][:wgs84],
					:width => options[:width],
					:height => options[:height]}
				
				# Call the block
				block.call(gc, options)
				
				# Add the canvas to the image and return the resulting image as PNG.
				gc.draw(image) rescue nil
				image.to_blob {self.format="png"}
			end
		end
	end
	
	register WMS
end
