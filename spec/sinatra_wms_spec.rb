require 'spec_helper'
require 'sinatra_wms'

describe SinatraWMS do
	describe 'merc_to_latlon' do
		it 'should work at the center of the coordinate system' do
			SinatraWMS::merc_to_latlon(0, 0).should == [0.0, 0.0]
		end
		
		it 'should work for other coordinates' do
			coords = SinatraWMS::merc_to_latlon(-626172.13571216376, 6887893.4928337997)
			(coords[0]*100000000).round.should == 5248278022
			(coords[1]*1000).round.should  == -5625
		end
	end
	
	describe 'get_html_for_map_at' do
		it 'should include the correct URL' do
			SinatraWMS::get_html_for_map_at('/test').should =~ /new OpenLayers.Layer.WMS\("[^"]+", "\/test"/
		end
		
		it 'shouldn\'t load Google Maps unless necessary' do
			SinatraWMS::get_html_for_map_at('/test').should_not =~ /maps.google.com\/maps\/api\/js/
		end
		
		it 'should load Google Maps when necessary' do
			SinatraWMS::get_html_for_map_at('/test', :baselayer=>:google_streets).should =~ /maps.google.com\/maps\/api\/js/
			SinatraWMS::get_html_for_map_at('/test', :baselayer=>:google_satellite).should =~ /maps.google.com\/maps\/api\/js/
			SinatraWMS::get_html_for_map_at('/test', :baselayer=>:google_hybrid).should =~ /maps.google.com\/maps\/api\/js/
			SinatraWMS::get_html_for_map_at('/test', :baselayer=>:google_terrain).should =~ /maps.google.com\/maps\/api\/js/
		end
		
		it 'should raise an error when an unknown baselayer is to be set' do
			expect {SinatraWMS::get_html_for_map_at('/test', :baselayer=>:foo)}.to raise_error
		end
	end
end
