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
end
