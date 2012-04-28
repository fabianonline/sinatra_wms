describe 'RMagick extensions' do
	before :each do
		@canvas = Magick::Draw.new()
		@canvas.wms_settings={:bbox=>[[0, 0], [1, 1]], :width=>256, :height=>256}
	end
	
	describe 'WGS84-compatible drawing methods' do
		before :each do
			@canvas.stub(:latlon_to_pixels).and_return([23,42])
		end
		
		describe "Methods using single coordinates" do
			before :each do
				@canvas.should_receive(:latlon_to_pixels).once.with(1, 2)
			end
			
			[:point, :bigpoint].each do |what|
				it "contains #{what.to_s}_wgs84" do
					@canvas.should_receive(what).with(23, 42)
					@canvas.send("#{what.to_s}_wgs84".to_sym, 1, 2)
				end
			end
			
			it 'contains color_wgs84' do
				@canvas.should_receive(:color).with(23, 42, 1)
				@canvas.color_wgs84(1, 2, 1)
			end
			
			it 'contains matte_wgs84' do
				@canvas.should_receive(:matte).with(23, 42, 1)
				@canvas.matte_wgs84(1, 2, 1)
			end
			
			it 'contains text_wgs84' do
				@canvas.should_receive(:text).with(23, 42, "hallo")
				@canvas.text_wgs84(1, 2, "hallo")
			end
			
			it "contains ellipse_wgs84" do
				@canvas.should_receive(:ellipse).with(23, 42, 100, 50, 0, 270)
				@canvas.ellipse_wgs84(1, 2, 100, 50, 0, 270)
			end
		end
		
		describe "Methods using double coordinates" do
			before :each do
				@canvas.should_receive(:latlon_to_pixels).once.with(1, 2).and_return([23,42])
				@canvas.should_receive(:latlon_to_pixels).once.with(3, 4).and_return([88,99])
			end
			
			[:circle, :line, :rectangle, :roundrectangle].each do |what|
				it "contains #{what.to_s}_wgs84" do
					@canvas.should_receive(what).with(23, 42, 88, 99)
					@canvas.send("#{what.to_s}_wgs84".to_sym, 1, 2, 3, 4)
				end
			end
		end
	end
	
	it "should contain bigpoint" do
		@canvas.should_receive(:rectangle).with(10, 21, 12, 23)
		@canvas.bigpoint(11, 22)
	end
	
	it "should calculate missing values when wms_settings are given" do
		@canvas = Magick::Draw.new()
		@canvas.wms_settings={:bbox=>[[-10, -5], [20, 30]], :width=>256, :height=>256}
		(@canvas.wms_settings[:max_sin_y]*1000000000).round.should == (2273030.92698769*1000000000).round
		(@canvas.wms_settings[:min_sin_y]*1000000000).round.should == (-1118889.974857959*1000000000).round
		(@canvas.wms_settings[:diff_y]*1000000000).round.should == (3391920.901845649*1000000000).round
		@canvas.wms_settings[:factor_x].should == 7
	end
end