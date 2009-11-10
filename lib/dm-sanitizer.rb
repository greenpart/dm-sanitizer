require 'pathname'
require 'rubygems'

require Pathname(__FILE__).dirname.expand_path + 'dm-sanitizer/version'

gem 'dm-core', '>= 0.9.4'
require 'dm-core'

gem 'sanitize', '>= 1.0.0'
require 'sanitize'

module DataMapper
  module Sanitizer
    def default_options
      {
        :mode_definitions  => {
          :default      => Sanitize::Config::DEFAULT,
          :restricted   => Sanitize::Config::RESTRICTED,
          :basic        => Sanitize::Config::BASIC,
          :relaxed      => Sanitize::Config::RELAXED
        },
        :default_mode   => :default,
        :with_dirty     => false
      }
    end
    module_function :default_options
    
    module ClassMethods
      def sanitize(options={})
        self.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def self.sanitization_options=(options)
            @sanitization_options = options
          end
          
          def self.sanitization_options
            @sanitization_options
          end
          
          def sanitization_options
            self.class.sanitization_options
          end
        RUBY
        
        self.sanitization_options = DataMapper::Sanitizer.default_options.merge(options)
        remap_sanitization_modes!
        check_sanitization_modes
        
        before :save, :sanitize! unless hooks_with_scope(:instance)[:update_hook][:before].include?({:name => :sanitize!, :from => self})
      end
      
      def disable_sanitization
        self.sanitization_options[:disabled] = true
      end
      
      private
      def remap_sanitization_modes!
        return unless @sanitization_options[:modes]
        result = {}
        @sanitization_options[:modes].each do |mode, group|
          if group.class == Array
            group.each {|item| result[item] = mode}
          else
            result[group] = mode
          end
        end
        @sanitization_options[:modes] = result
      end
      
      def check_sanitization_modes
        return unless @sanitization_options[:modes]
        @sanitization_options[:modes].each do |property, mode|
          raise Exception.new("Sanitization mode :#{mode} is not defined") unless @sanitization_options[:mode_definitions].has_key?(mode)
        end
      end
    end
    
    module InstanceMethods
      def sanitize!
        options = self.class.sanitization_options
        return false if options[:disabled]
        
        self.class.properties.each do |property|
          property_name = property.name.to_sym
          
          next unless property.type == String || property.type == DataMapper::Types::Text
          next if !new? && !options[:with_dirty] && !attribute_dirty?(property.name.to_sym)
          next if options[:exclude] && options[:exclude].include?(property_name)
          
          property_mode = options[:modes] ? options[:modes][property_name] || options[:default_mode] : options[:default_mode]
          
          sanitize_property!(property_name, property_mode)
        end
        return true
      end
      
      def sanitize_property!(name, mode)
        value = self.send( name )
        return if value.nil? || value.empty?
        sanitized_value = Sanitize.clean(value, self.class.sanitization_options[:mode_definitions][mode])
        self.send( name.to_s+'=', sanitized_value)
      end
    end
    
    def self.included(receiver)
      receiver.extend( ClassMethods )
      receiver.send( :include, InstanceMethods )
      receiver.send( :sanitize )
    end
  end
end

DataMapper::Model.append_inclusions DataMapper::Sanitizer