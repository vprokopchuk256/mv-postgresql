require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "mv-postgresql"
  gem.homepage = "http://github.com/vprokopchuk256/mv-postgresql"
  gem.license = "MIT"
  gem.summary = "Migration Validators project postgresql driver"
  gem.summary = "Postgresql constraints in migrations similiar to ActiveRecord validations"
  gem.description = "Postgresql constraints in migrations similiar to ActiveRecord validations"
  gem.email = "vprokopchuk@gmail.com"
  gem.authors = ["Valeriy Prokopchuk"]
  gem.files = Dir.glob('lib/**/*.rb')
  gem.required_ruby_version = '>= 2.0'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mv-postgresql #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
