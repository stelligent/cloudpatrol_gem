# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','cloudpatrol','version.rb'])
spec = Gem::Specification.new do |s|
  s.name = 'cloudpatrol'
  s.version = Cloudpatrol::VERSION
  s.author = 'Stelligent'
  s.email = 'developers@stelligent.com'
  s.homepage = 'http://stelligent.com'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Command-line tool that helps you keep Amazon cloud clean'
# Add your other files here if you make them
  s.files = %w(
bin/cloudpatrol
lib/cloudpatrol/tasks.rb
lib/cloudpatrol/version.rb
lib/cloudpatrol.rb
  )
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc','cloudpatrol.rdoc']
  s.rdoc_options << '--title' << 'cloudpatrol' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'cloudpatrol'
  s.required_ruby_version = '~> 2.0.0'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('aws-sdk', '~> 1.11.0')
  s.add_runtime_dependency('gli','2.6.0')
end
