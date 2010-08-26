require 'pathname'
require 'rubygems'
require 'rake'
require "rake/clean"
require "rake/gempackagetask"

ROOT    = Pathname(__FILE__).dirname.expand_path
JRUBY   = RUBY_PLATFORM =~ /java/
WINDOWS = Gem.win_platform?
SUDO    = (WINDOWS || JRUBY) ? '' : ('sudo' unless ENV['SUDOLESS'])

require ROOT + 'lib/dm-sanitizer/version'

AUTHOR = 'Sergei Zimakov'
EMAIL  = 'zimakov@gmail.com'
GEM_NAME = 'dm-sanitizer'
GEM_VERSION = DataMapper::Sanitizer::VERSION
GEM_DEPENDENCIES = [['dm-core', '>= 0.9.4'], ['sanitize', '>= 1.0.0']]
GEM_CLEAN = %w[ log pkg coverage ]
GEM_EXTRAS = { :has_rdoc => true, :extra_rdoc_files => %w[ README.txt LICENSE History.txt ] }

PROJECT_NAME = 'dm-sanitizer'
PROJECT_URL  = "http://github.com/pat/#{GEM_NAME}/tree/master/"
PROJECT_DESCRIPTION = PROJECT_SUMMARY = 'DataMapper plugin for automated/configurable user input sanitization.'

[ ROOT ].each do |dir|
  Pathname.glob(dir.join('tasks/**/*.rb').to_s).each { |f| require f }
end
# 
# spec = Gem::Specification.new do |s|
#   s.name         = GEM_NAME
#   s.version      = GEM_VERSION
#   s.platform     = Gem::Platform::RUBY
#   s.author       = AUTHOR
#   s.email        = EMAIL
#   s.homepage     = PROJECT_URL
#   s.summary      = PROJECT_SUMMARY
#   s.description  = PROJECT_DESCRIPTION
#   s.require_path = 'lib'
#   s.files        = %w[ LICENSE README.txt Rakefile History.txt TODO ] + Dir['lib/**/*'] + Dir['spec/**/*']
#   s.rubyforge_project = GEM_NAME
#  
#   # rdoc
#   s.has_rdoc         = false
#   s.extra_rdoc_files = %w[ LICENSE README.txt History.txt ]
#  
#   # Dependencies
#   GEM_DEPENDENCIES.each {|dep| s.add_dependency( dep[0], dep[1] )}
# end
#  
# Rake::GemPackageTask.new(spec) do |package|
#   package.gem_spec = spec
# end
# 
# Specs

begin
  gem 'rspec', '~>1.2'
  require 'spec'
  require 'spec/rake/spectask'

  task :default => [ :spec ]

  desc 'Run specifications'
  Spec::Rake::SpecTask.new(:spec) do |t|
    t.spec_opts << '--options' << 'spec/spec.opts' if File.exists?('spec/spec.opts')
    t.spec_files = Pathname.glob((ROOT + 'spec/**/*_spec.rb').to_s).map { |f| f.to_s }

    begin
      gem 'rcov', '~>0.8'
      t.rcov = JRUBY ? false : (ENV.has_key?('NO_RCOV') ? ENV['NO_RCOV'] != 'true' : true)
      t.rcov_opts << '--exclude' << 'spec'
      t.rcov_opts << '--text-summary'
      t.rcov_opts << '--sort' << 'coverage' << '--sort-reverse'
    rescue LoadError
      # rcov not installed
    end
  end
rescue LoadError
  # rspec not installed
end

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name = GEM_NAME
    gem.summary = PROJECT_SUMMARY
    gem.description = PROJECT_DESCRIPTION
    gem.email = EMAIL
    gem.homepage = PROJECT_URL
    gem.authors = [ AUTHOR ]

    gem.rubyforge_project = PROJECT_NAME

    gem.add_dependency 'dm-core', '>= 0.9.4'
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