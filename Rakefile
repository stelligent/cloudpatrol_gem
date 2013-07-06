require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc","lib/**/*.rb","bin/**/*")
  rd.title = 'CloudPatrol'
end

spec = eval(File.read('cloudpatrol.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
end
task :default => :package
