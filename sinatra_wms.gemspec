# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sinatra_wms/version"

Gem::Specification.new do |s|
  s.name        = "sinatra_wms"
  s.version     = SinatraWMS::VERSION
  s.authors     = ["Fabian Schlenz (@fabianonline)"]
  s.email       = ["mail@fabianonline.de"]
  s.homepage    = "http://github.com/fabianonline/sinatra_wms"
  s.summary     = "Extends Sinatra to allow the developer to easily build a WMS server"
  s.description = %q(A WMS (Web Map Service) is a great way to show lots of geolocated data on a map. Instead of generating static images (which will either be huge or don't have enough resolution), a WMS allows you to dynamically zoom in and out of your dataset.

This gem allows you to very easily represent your data via a WMS. On one hand it extends Sinatra to give it a method called "wms" to process WMS-requests; on the other hand it extends RMagick to allow the developer to use coordinates in the methods used for drawing.

Convenient methods to easily generate HTML code to show your WMS data on top of OpenStreetMaps or Google Maps are also included.

Current test status: [![Build Status](https://secure.travis-ci.org/fabianonline/sinatra_wms.png?branch=master)](http://travis-ci.org/fabianonline/sinatra_wms) )

  s.rubyforge_project = "sinatra_wms"

  s.add_dependency('sinatra', '>=1.0.0')
  s.add_dependency('rmagick')
  s.add_development_dependency('rspec', '~> 2.9')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.extra_rdoc_files = ["README.rdoc"]
  s.require_paths = ["lib"]
end
