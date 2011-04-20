# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2011 by Hannes Georg
#
require 'facets/array/extract_options.rb'
require 'facets/hash/deep_merge.rb'
require 'sync'
require 'logger'
require 'set'
require 'humanized/compiler.rb'
require 'humanized/source.rb'
require 'humanized/interpolater.rb'
module Humanized
# A Humanizer has one simple task: <b>create strings in its language/dialect/locale/whatever!</b>
#
# There should be one Humanizer per each configuration, but they can share their three components:
# * {#source a source} which holds all language data ( mainly strings )
# * {#compiler a compiler} which compiles the found strings
# * {#interpolater an interpolater} which holds the methods which can be used in an interpolation
#
# The most important method you may use is {#[]}.
class Humanizer
  
  IS_STRING = lambda{|x| x.kind_of? String }
  
  class << self
    
  private
  
    # Defines a component on this class and all subclasses.
    def component( name, options = {}, &initializer )
      @components ||= {}
      options = options.dup
      if !block_given?
        initializer = lambda{|value| value}
      end
      options[:initializer] = initializer
      options.freeze
      @components[name.to_sym] = options
      attr_accessor name
      public name.to_sym
      protected "#{name.to_s}=".to_sym
      if options[:delegate]
        if options[:delegate].kind_of? Hash
          options[:delegate].each do | from, to |
            module_eval <<RB
  def #{from.to_s}(*args, &block)
    #{name.to_s}.#{to.to_s}(*args,&block)
  end
RB
          end
        elsif options[:delegate].respond_to? :each
          options[:delegate].each do | from |
            module_eval <<RB
  def #{from.to_s}(*args, &block)
    #{name.to_s}.#{from.to_s}(*args,&block)
  end
RB
          end
        end
        
      end
    end
    
  public
    def each_component
      klass = self
      components = Set.new
      while( klass )
        a = klass.instance_variable_get("@components")
        if a
          a.each do |name, options|
            unless components.include?(name)
              yield(name, options)
              components << name
            end
          end
        end
        klass = klass.superclass
      end
      
    end
    
  end
  
  component :interpolater do |value|
    value || Interpolater.new
  end
  
  component :source, :delegate =>[:package, :load , :<<, :get ] do |value|
    if value.kind_of? Source
      value
    elsif value.kind_of? Hash
      Source.new(value)
    elsif value.nil?
      Source.new
    else
      raise ArgumentError, "Expected :source to be a kind of Humanized::Source, Hash or nil."
    end
  end
  
  component :compiler do |value|
    value || Compiler.new
  end
  
  component :logger do |value|
    if value.kind_of? Logger
      value
    elsif value.respond_to? :write and value.respond_to? :close
      Logger.new(value)
    elsif value.nil?
      Humanized.logger
    elsif value.kind_of? FalseClass
      value
    else
      raise ArgumentError, "Expected :logger to be a kind of Logger, IO, nil or false."
    end
  end
  
# Creates a new Humanizer
#
# @option components [Object] :interpolater This object which has all interpolation methods defined as public methods.
# @option components [Compiler] :compiler A compiler which can compile strings into procs. (see Compiler)
# @option components [Source] :source A source which stores translated strings. (see Source)
# @option components [Logger, IO, false] :logger A logger for this Humanizer or false to disable logging.
  def initialize(components = {})
    self.class.each_component do |name, options|
      self.send("#{name}=".to_sym, options[:initializer].call(components[name]))
    end
  end
  
# Creates a new Humanizer deriving compponents from another humanizer
# @param humanizer [Humanizer]
# @see #initialize
  def self.new_from( humanizer, components = {} )
    unless humanizer.kind_of? Humanizer
      raise ArgumentError, "Expected an instance of Humanized::Humanizer, but received #{humanizer.inspect}"
    end
    if self <= humanizer.class
      components = components.dup
      humanizer.class.each_component do |name, options|
        unless components.key? name
          components[name] = humanizer.send(name)
        end
      end
      return self.new(components)
    else
       raise ArgumentError, "I don't know if that's a good idea what you want. Maybe will be allowed later..."
    end
  end
  
  
# Creates a new Humanizer which uses the interpolater, compiler and source of this Humanizer unless other values for them were specified.
# @see #initialize
  def renew(components)
    self.class.new_from(self, components)
  end
  
# Creates a String from the input. This will be the most used method in application code.
# It expects a {Query} as argument. Anything that is not a {Query} will be converted into a {Query} using the "_"-method.
# This enables you to pass any object to this method. The result is mainly determined by result of the "_"-method.
# For 
#
# @param [Query, #_, Object] *args
# @return [String]
  def [](*args)
    it = args._
    
    vars = it.variables
    default = it.default
    result = @source.get(it, :default=>default, :accepts=>IS_STRING)
    result = default unless result.kind_of? String
    if result.kind_of? String
      return interpolate(result,vars)
    else
      if logger
        logger.error do
          "Expected to retrieve a String, but got: #{result.inspect}\n\tQuery: #{it.inspect}"
        end
      end
      return ""
    end
  end

# Stores a translation
  def []=(it, *rest)
    last = rest.pop
    @source.store(it._(*rest).first,last)
  end
  
  def interpolate(str,vars={})
    return @compiler.compile(str).call(self,vars)
  rescue Exception => e
    return handle_interpolation_exception(e, str, vars)
  end
  
protected
  def handle_interpolation_exception(e, str, vars)
    if logger
      logger.error do
        "Failed interpolating \"#{str}\"\n\tVariables: #{vars.inspect}\n\tMessage: #{e.message}\n\tTrace:\t" + e.backtrace.join("\n\t\t")
      end
    end
    return FailedInterpolation.new(e, str, vars)
  end
  
end
end
