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
require "facets/module/home.rb"
require "facets/module/basename.rb"
require "facets/module/anonymous.rb"
require "facets/module/alias_method_chain.rb"

def Humanized(obj)
  return obj.humanization_key
end

module Humanized

  module HasNaturalGenus
    
    def self.included(base)
      base.class_eval do
        alias_method_chain :humanization_key, :genus
      end
    end
    
    def genus
      return super if defined? super
      raise NoMethodError, "Please implent a method `genus`!"
    end
    
    def humanization_key_with_genus
      return humanization_key_without_genus.optionaly(self.genus)
    end
    
    
  end

  class TranslationMissing < StandardError
    
    attr_reader :keys
    
    def initialize(keys)
      @keys = keys
      super("Missing Translation: #{keys.inspect}")
    end
    
  end

  class Scope
    
    include Enumerable
  
    NAME_REGEX = /[a-z_]+/.freeze
    OPTIONAL_NAME_REGEX = /([a-z_]+)\?/.freeze
    
    attr_accessor :path, :depth
  
    def self.from_str(str)
      Scope.new([ str.explode('.').map(&:to_sym) ])
    end
  
    def initialize(path = [[]], depth = 1)
      @path = path.uniq
      @path.each do |path|
        path.freeze
      end
      @path.freeze
      @depth = depth
    end
  
    def method_missing(name, *args, &block)
      name_str = name.to_s
      if OPTIONAL_NAME_REGEX =~ name_str
        return ( self + $1 | self )._(*args,&block)
      end
      if NAME_REGEX =~ name_str
        return ( self + name )._(*args,&block)
      end
      super
    end
    
    def ==(other)
      return false unless other.kind_of? Scope
      return @path == other.path
    end
    
    def |(other)
      return other if @path.none?
      sp = self.path
      sd = self.depth
      op = other.path
      od = other.depth
      result = []
      i = 0
      j = 0
      while i < sp.size and j < op.size
        result.concat sp[i,sd] if sp.size > i
        result.concat op[j,od] if op.size > j
        i = i + sd
        j = j + od
      end
      return Scope.new( result, sd + od )
    end
  
    def include?(path)
      return @path.include? path
    end
    
    def optionaly(k)
      return self._(k) | self
    end
    
    def [](*args)
      sp = self.path
      sd = self.depth
      op = args
      od = 1
      result = []
      self.each do |path|
        args.each do |arg|
          result << path.concat([arg])
        end
      end
      return Scope.new( result, args.size )
    end
    
    def +(*args)
      return self if args.none?
      if( args.first.kind_of? Scope )
        return args.first if @path.none?
        # TODO: maybe modify depth too?
        new_path = []
        @path.each do |x|
          args.first.each do |path|
            new_path << x + path
          end
        end
        return Scope.new(new_path,args.first.depth)
      end
      if @path.none?
        return Scope.new( [args] , 1 )
      end
      return Scope.new( @path.map{|x| x + args} , @depth )
    end
    
    def _(*args,&block)
      thiz = self
      vars = nil
      loop do
        return thiz if args.none?
        arg = args.shift
        if arg.kind_of? Symbol or arg.kind_of? Scope
          thiz += arg
        elsif arg.kind_of? Hash
          vars = arg
        else
          thiz += arg._
        end
      end
      if block_given?
        thiz = thiz.instance_eval(&block)
      end
      if vars
        return thiz.with_variables(arg)
      else
        return thiz
      end
    end
  
    def with_variables(vars)
      ScopeWithVariables.new(@path, @depth, vars)
    end
  
    def inspect
      return '(' + @path.map{|p| p.join '.'}.join(' , ') + ')'
    end
  
    #alias_method :to_str, :inspect
    #def to_ary
    #  @path
    #end
  
    def each(&block)
      @path.each(&block)
    end
  
    def humanization_key
      return self
    end
  end


  class ScopeWithVariables < Scope
    
    attr_accessor :variables
    
    def initialize(path = [[]], depth = 1, vars = {})
      super(path,depth)
      @variables = vars
    end
    
    def to_ary
      [self, @variables]
    end
    
    def with_variables(vars)
      ScopeWithVariables.new(@path, @depth, @variables.merge(vars))
    end
    
  end
  
  L = Scope.new([[]],1)
  None = Scope.new([],0)
  
  def humanization_key!
    if self.anonymous?
      return self.superclass.humanization_key
    end
    h = self.home
    if h != Object and h.respond_to? :humanization_key
      result = h.humanization_key + self.basename.downcase.to_sym
    else
      result = L.+(*self.name.split('::').map{|s| s.downcase.to_sym })
    end
    thiz = self
    if defined? thiz.superclass and self.superclass != Object
      return result | self.superclass.humanization_key
    end
    return result
  end

  def humanization_key
    @humanization_key ||= humanization_key!
  end

  def _(*args,&block)
    humanization_key._(*args,&block)
  end

end
require "humanized/interpolater.rb"
require "humanized/ref.rb"
require "humanized/humanizer.rb"

class Module
  include Humanized
end
class Object
  def humanization_key
    self.class.humanization_key
  end
  def _(*args,&block)
    self.humanization_key._(*args,&block)
  end
end
class Symbol
  def _(*args,&block)
    Humanized::Scope.new([[self]])._(*args,&block)
  end
end
class Array
  def _(*args,&block)
    if self.any?
      return self[0]._(*self[1..-1])._(*args,&block)
    else
      Humanized::None
    end
  end
end