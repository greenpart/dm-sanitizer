require 'pathname'
require 'rubygems'
 
gem 'rspec', '~>1.3'
require 'spec'
 
gem 'dm-core', '>= 1.0'
require 'dm-core'
require 'dm-migrations'

gem 'sanitize', '>= 1.0.0'
require 'sanitize'
 
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-sanitizer'
 
def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s
 
  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end
 
ENV['ADAPTER'] ||= 'sqlite3'
 
HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')