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
	
	##
	# Returns generic HTML code to display a transparent basemap (OSM or Google Maps) and images from the WMS.
	#
	# * +url+ has to be the full URL to the WMS. Since this module can't use Sinatra's helper,
	#   please call it using this helper, e.g. +url("/wms")+.
	# * Other options used are:
	#   * +:title+ - Sets the HTML title attribute.
	#   * +:opacity:+ - Sets the opacity of the OSM map in the background.
	#   * +:datasource_name+ - Sets the name of the WMS source in the layer selector menu.
	#   * +:baselayer+ - Which baselayer to use. Supported values are:
	#     * +:osm+ (default)
	#     * +:google_streets+
	#     * +:google_satellite+
	#     * +:google_hybrid+
	#     * +:google_terrain+
	def self.get_html_for_map_at(url, options={})
		options[:title] ||= "Sinatra-WMS"
		options[:opacity] ||= 1.0
		options[:datasource_name] ||= "WMS-Data"
		options[:baselayer] ||= :osm
		
		baselayer_definition = case options[:baselayer]
			when :osm then "new OpenLayers.Layer.OSM()"
			when :google_streets then 'new OpenLayers.Layer.Google("Google Streets")'
			when :google_satellite then 'new OpenLayers.Layer.Google("Google Satellite", {type: google.maps.MapTypeId.SATELLITE})'
			when :google_hybrid then 'new OpenLayers.Layer.Google("Google Hybrid", {type: google.maps.MapTypeId.HYBRID})'
			when :google_terrain then 'new OpenLayers.Layer.Google("Google Terrain", {type: google.maps.MapTypeId.TERRAIN})'
			else raise "Unknown value for baselayer: #{options[:baselayer]}"
		end

		%Q{
		<html>
			<head>
				<title>#{options[:title]}</title>
				#{options[:baselayer].to_s[0..6]=='google_'  ?  '<script src="http://maps.google.com/maps/api/js?v=3.2&sensor=false"></script>'  :  '' }
				<script src="http://openlayers.org/api/OpenLayers.js"></script>
				<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
			</head>
			<body>
				<div style="width:100%; height:100%" id="map"></div>
				<script type="text/javascript" defer="defer">
					var imagebounds = new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34);

					var map = new OpenLayers.Map('map');
					map.addControl(new OpenLayers.Control.LayerSwitcher());

					var base_layer = #{baselayer_definition};
					map.addLayer(base_layer);
					base_layer.setOpacity(#{options[:opacity]});
					

					var layer = new OpenLayers.Layer.WMS("#{options[:datasource_name]}", "#{url}", {transparent: true}, {maxExtent: imagebounds});

					map.addLayer(layer);
					map.zoomToExtent(imagebounds);
				</script>
			</body>
		</html>}
	end
end
