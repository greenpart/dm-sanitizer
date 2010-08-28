require 'pathname'
require 'rubygems'
require 'rake'
require "rake/clean"

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name = 'dm-sanitizer'
    gem.summary = 'DataMapper plugin for automated/configurable user input sanitization.'
    gem.description = 'DataMapper plugin for automated/configurable user input sanitization.'
    gem.email = 'zimakov@gmail.com'
    gem.homepage = "http://github.com/pat/dm-sanitizer/tree/master/"
    gem.authors = [ 'Sergei Zimakov' ]

    gem.rubyforge_project = 'dm-sanitizer'

    gem.add_dependency 'dm-core', '>= 0.10.1'
    gem.add_dependency 'sanitize', '>= 1.0.0'

    gem.add_development_dependency 'rspec', '~> 1.3'
    gem.add_development_dependency 'jeweler', '~> 1.4'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }

rescue LoadError => e
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
  puts '-----------------------------------------------------------------------------'
  puts e.backtrace # Let's help by actually showing *which* dependency is missing
end

gem 'rspec', '~>1.3'
require 'spec'
require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec)
