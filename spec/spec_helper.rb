require 'rspec'
require 'sinatra'
require 'rack/test'
require 'sinatra_wms'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |config|
	config.color_enabled = true
	config.formatter = 'documentation'
	config.include Rack::Test::Methods
end

def app
	@app ||= TestApp.new
end

class TestApp < Sinatra::Application
	wms '/wms' do |canvas, options|
		test_method(canvas, options)
	end
	
	def self.test_method(canvas, options)
	end
end