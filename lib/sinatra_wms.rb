require "sinatra_wms/version"
require "sinatra_wms/sinatra_extension"
require "sinatra_wms/rmagick_extension"

module SinatraWMS
	
	##
	# Convert a set of coordinates from sperical mercator to WGS84.
	def self.merc_to_latlon(x, y)
		lon = (x / 6378137.0) / Math::PI * 180
		lat = Math::atan(Math::sinh(y / 6378137.0)) / Math::PI * 180
		return [lat, lon]
	end

	def self.deg_sin(x)
		Math.sin(x * Math::PI / 180)
	end
	
	##
	# Returns generic HTML code to display a transparent OSM map and images from the WMS.
	#
	# * +url+ has to be the full URL to the WMS. Since this module can't use Sinatra's helper,
	#   please call it using this helper, e.g. +url("/wms")+.
	# * Other options used are:
	#   * +:title+ - Sets the HTML title attribute.
	#   * +:opacity:+ - Sets the opacity of the OSM map in the background.
	#   * +:datasource_name+ - Sets the name of the WMS source in the layer selector menu.
	def self.get_html_for_map_at(url, options={})
		options[:title] ||= "Sinatra-WMS"
		options[:opacity] ||= 1
		options[:datasource_name] ||= "WMS-Data"

		%Q{
		<html>
			<head>
				<title>#{options[:title]}</title>
				<script src="http://openlayers.org/api/OpenLayers.js"></script>
				<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
			</head>
			<body>
				<div style="width:100%; height:100%" id="map"></div>
				<script type="text/javascript" defer="defer">
					var imagebounds = new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34);

					var map = new OpenLayers.Map('map');
					map.addControl(new OpenLayers.Control.LayerSwitcher());

					var osm_layer = new OpenLayers.Layer.OSM();
					osm_layer.setOpacity(#{options[:opacity]});
					map.addLayer(osm_layer);

					var layer = new OpenLayers.Layer.WMS("#{options[:datasource_name]}", "#{url}", {transparent: true}, {maxExtent: imagebounds});

					map.addLayer(layer);
					map.zoomToExtent(imagebounds);
				</script>
			</body>
		</html>}
	end
end
