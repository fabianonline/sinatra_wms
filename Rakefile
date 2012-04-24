require 'rdoc/task'
require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RDoc::Task.new do |r|
	r.main = "README.rdoc"
	r.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

RSpec::Core::RakeTask.new('spec')

task :default=>:spec
