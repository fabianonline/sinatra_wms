require 'sinatra/base'
module Sinatra
	module WMS
		def wms(url, &block)
			get url do
				headers "Content-Type" => "image/png"
				# convert the given parameters to lowercase symbols
				options = params.inject({}) {|hash, (key, value)| hash[key.to_s.downcase.to_sym] = value; hash }
				
				# interpret :width and :height as integer
				[:width, :height].each {|what| options[what] = options[what].to_i}
				
				# convert bounding box coordinates
				bbox = options[:bbox].split(',').collect{|v| v.to_f}
				options[:bbox] = {:original => [[bbox[0], bbox[1]], [bbox[2], bbox[3]]]}
				if options[:srs]=="EPSG:900913"
					options[:bbox][:google] = options[:bbox][:original]
					options[:bbox][:wgs84] = [*SinatraWMS::merc_to_latlon(bbox[0], bbox[1])], [*SinatraWMS::merc_to_latlon(bbox[2], bbox[3])]
				else
					raise "Unexpected Projection (srs): #{options[:srs]}"
				end
				options[:zoom] = (17-((Math.log((options[:bbox][:google][1][0]-options[:bbox][:google][0][0]).abs*3.281/500) / Math.log(2)).round))

				image = Magick::Image.new(options[:width], options[:height]) { self.background_color = 'transparent' }
				gc = Magick::Draw.new
				
				gc.wms_settings = {
					:bbox => options[:bbox][:wgs84],
					:width => options[:width],
					:height => options[:height]}
				
				block.call(gc, options)
				
				gc.draw(image) rescue nil
				image.to_blob {self.format="png"}
			end
		end
	end
	
	register WMS
end
