require 'spec_helper'

describe "Sinatra extensions:" do
	describe "The wms method" do
		before(:each) do
			@parameters = {"TRANSPARENT"=>"TRUE",
			"SERVICE"=>"WMS",
			"VERSION"=>"1.1.1",
			"REQUEST"=>"GetMap",
			"STYLES"=>"",
			"FORMAT"=>"image/png",
			"SRS"=>"EPSG:900913",
			"BBOX"=>"626172.135625,6261721.35625,1252344.27125,6887893.491875",
			"WIDTH"=>"256",
			"HEIGHT"=>"256"}
		end
	
		it "should be provided" do
			Sinatra::Application.methods.should include( RUBY_VERSION>="1.9"  ?  :wms  :  "wms" )
		end

		describe "should use the given block" do
			it "and yield it" do
				TestApp.should_receive(:test_method)
				get '/wms', @parameters
				last_response.status.should == 200
			end
			
			it "should return an error if parameters are missing" do
				get '/wms'
				last_response.status.should == 400
			end
			
			it "should return an error if an unknown SRS value is used" do
				@parameters["SRS"] = "EPSG:1234567"
				get '/wms', @parameters
				last_response.status.should == 400
			end
			
			it "should return data marked as image/png" do
				get '/wms', @parameters
				last_response.header["Content-Type"].should == "image/png"
			end
			
			it "should return a PNG image" do
				get '/wms', @parameters
				last_response.body[0..7].should == "\x89PNG\x0d\x0a\x1a\x0a"
			end 
			
			describe "with options" do
				before(:each) do
					TestApp.should_receive(:test_method) do |*args|
						args.size.should == 2
						@options = args[1]
					end
					get '/wms', @parameters
				end
				
				it("being a Hash") { @options.should be_a Hash }
				it("containing all necessary values") { @options.should include(:zoom, :width, :bbox, :height) }
				it("with a correct zoom level") { @options[:zoom].should == 5 }
				
				describe("with bounding boxes") do
					it("of multiple types") { @options[:bbox].should include(:original, :google, :wgs84) }
					it("with the original value") { @options[:bbox][:original].should == [[626172.135625,6261721.35625],[1252344.27125,6887893.491875]] }
					it("with the original one equal to the google one") { @options[:bbox][:google].should == @options[:bbox][:original] }
					it("with a correctly calculated WGS84 one") do
						# Comparing floating point numbers isn't easy, so we use this workaround
						a = @options[:bbox][:wgs84].flatten.collect{|elm| (elm*1000000000000).round}
						b = [[48.9224992586133, 5.62499999921699], [52.4827802168329, 11.249999998434]].flatten.collect{|elm| (elm*1000000000000).round}
						a.should == b
					end
				end
			end
			
			describe "with a Magick::Draw object" do
				before(:each) do
					TestApp.should_receive(:test_method) do |*args|
						args.size.should == 2
						@draw = args[0]
						@options = args[1]
					end
					get '/wms', @parameters
				end
				
				it "should be a Magick::Draw object" do
					@draw.should be_a Magick::Draw
				end
				
				context "with wms_settings" do
					it("being a hash") { @draw.wms_settings.should be_a(Hash) }
					it("having all necessary keys") { @draw.wms_settings.should include(:min_sin_y, :width, :max_sin_y, :diff_y, :bbox, :factor_x, :height)}
					it("with a correct bbox") { @draw.wms_settings[:bbox].should == @options[:bbox][:wgs84]}
				end
			end
		end
	end
end