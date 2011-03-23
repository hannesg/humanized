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

module Humanized
# A {Scope} is _the_ way to tell a {Humanizer} what you want from it.
# It contains of three parts:
# * {#path a list of paths}, which will be looked up in a {Source source}
# * {#default a default}, which will be used if nothing was found
# * {#variables variables}, which will be used to interpolate a found string
# That's all you need!
# The good thing: you'll unlikly create a scope by hand, that's done automatically with "_"!
#
# == Examples
#
# The basic steps:
#  # Creates a scope which looks up ":a" with no default and no variables:
#  :a._
#  # Creates a scope which looks up nothing, has a default of "String" but no variables:
#  "String"._
#  # Creates a scope which looks up nothing, has no default but the variable :foo = "bar"
#  {:foo => 'bar'}._
#
# Combining these steps brings the power:
#
#  # Creates a scope which looks up ":a", has a default of "String" and the variable :foo = "bar"
#  :a._ + "String"._ + {:foo => 'bar'}._
#  # Shorthand for this:
#  :a._("String", :foo => 'bar')
#
# The "_"-method is overloaded for many things. For example for inheritance:
#  
#  module Site
#    class User
#    end
#    class Admin < User
#    end
#  end
#  # Creates a scope matching ":site, :admin" or ":site, :user":
#  Site::Admin._
#  # This creates the same:
#  Site::Admin.new._
#
# And for Arrays:
#  # This matches ":a, :b, :c":
#  [:a, :b, :c]._
#
# Finally for Scopes itself:
#  # Given scope is a Scope this is always true:
#  scope._._ == scope._
#
# I could continue the whole day ...
#
# == Tricks
# A Scope responds to any method giving a new Scope suffixed by the method name
#  # Looks up ":a, :b, :c"
#  :a._.b.c
# "_" can also take a block which is instance evaled on the scope:
#  # Looks up ":a, :b, :c"
#  :a._{ b.c }
#  # Looks up ":a, :x" or ":a, :y"
#  :a._{ x | y }
# There are two special scopes:
#  # Looks up "", which will we be the whole source
#  Humanized::Scope::Root
#  # Looks up nothing
#  Humanized::Scope::None
#
  class Scope
    
    include Enumerable
# @private
    UNMAGIC_METHODS = [:to_ary]
# @private
    NAME_REGEX = /[a-z_]+/.freeze
# @private
    OPTIONAL_NAME_REGEX = /([a-z_]+)\?/.freeze
    
    attr_reader :path, :depth, :variables, :default
  
    def self.from_str(str)
      Scope.new([ str.explode('.').map(&:to_sym) ])
    end
  
    def initialize(path = [[]], depth = 1, variables = {}, default = nil)
      @path = path.uniq
      @path.each do |path|
        path.freeze
      end
      @path.freeze
      @depth = depth
      @variables = variables
      @default = default
    end

# This method is a here to enable awesome DSL.
#== Example
#  s = Scope.new
#  s.defining.a.scope.using_methods # gives: (defining.a.scope.using_methods)
#  s.defining(:a,:scope,:using_methods) # gives: (defining.a.scope.using_methods)
#  s.this{ is.awesome | is.awful } # gives: (this.is.awesome , this.is.awful)
# 
    def method_missing(name, *args, &block)
      return super if UNMAGIC_METHODS.include? name
      name_str = name.to_s
      if OPTIONAL_NAME_REGEX =~ name_str
        return ( self + $1.to_sym | self )._(*args,&block)
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
    
# Creates a {Scope scope} which matches either self or the other scope.
# @example
#  # this will match ":to_be" and ":not_to_be":
#  ( :to_be._ | :not_to_be._ )
#
# @param [Scope] other another scope
# @return [Scope] a new scope
    def |(other)
      return other if @path.none?
      return self.dup if other.none?
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
      return Scope.new( result, sd + od , self.variables.merge(other.variables), other.default)
    end
    
# Creates a new scope which will optionally match this scope suffixed with the key.
#
# @example
#  # this will match ":borat_is_stupid, :not" and ":borat_is_stupid":
#  :borat_is_stupid._.optionally(:not)
#
# @param key 
# @return [Scope] a new scope
    def optionally(key)
      return self._(key) | self
    end
    
    def [](*args)
      sp = self.path
      sd = self.depth
      op = args
      od = 1
      result = []
      self.each do |path|
        args.each do |arg|
          result << path + [arg]
        end
      end
      return Scope.new( result, args.size )
    end
    
# Chain scopes together
# @example
#  # this will match ":a,:b,:c"
#  :a._ + :b._ + :c._
#
# @param *args an array of scopes for chaining
# @return [Scope]
    def +(*args)
      return self if args.none?
      if( args.first.kind_of? Scope )
        s = args.first
        return Scope.new(@path, @depth, variables.merge(s.variables), self.default || s.default ) if @path.none? or s.path.none?
        # TODO: maybe modify depth too?
        new_path = []
        @path.each do |x|
          s.each do |path|
            new_path << x + path
          end
        end
        return Scope.new(new_path, s.depth, variables.merge(s.variables), self.default || s.default )
      end
      if @path.none?
        return self
      end
      return Scope.new( @path.map{|x| x + args} , @depth , @variables, @default)
    end
    
    def _(*args,&block)
      thiz = self
      vars = nil
      loop do
        break if args.none?
        arg = args.shift
        if arg.kind_of? Symbol or arg.kind_of? Scope
          thiz += arg
        elsif arg.class == Hash
          vars = arg
        else
          thiz += arg._
        end
      end
      if block_given?
        thiz = thiz.instance_eval(&block)
      end
      if vars
        return thiz.with_variables(vars)
      else
        return thiz
      end
    end
  
    def with_variables(vars)
      Scope.new(@path, @depth, variables.merge(vars), @default)
    end
    
    def with_default(default)
      Scope.new(@path, @depth, @variables, default)
    end
  
    def inspect
      return '(' + @path.map{|p| p.join '.'}.join(' , ') + ' '+depth.to_s+' v='+variables.inspect+' d='+default.inspect+')'
    end

# Iterates over all possible paths.
# @yieldparam [Array] path
    def each(&block)
      @path.each(&block)
    end
  
    def humanization_key
      return self
    end
    
    Root = self.new([[]],1)
    None = self.new([],0)
    Meta = self.new([[:__meta__]],1)
    
    
  end
end