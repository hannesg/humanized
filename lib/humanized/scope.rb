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
# A Scope is basically an array of paths which could be looked up in a Source.
# To make the Scope handling a lot easier, there are a lot of handy methods.
  class Scope
    
    include Enumerable
    
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
      return Scope.new( result, sd + od , other.variables, other.default)
    end
  
    def include?(path)
      return @path.include? path
    end
    
    def optionally(k)
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
          result << path + [arg]
        end
      end
      return Scope.new( result, args.size )
    end
    
    def +(*args)
      return self if args.none?
      if( args.first.kind_of? Scope )
        s = args.first
        return Scope.new(@path, @depth, variables.merge(s.variables), s.default ) if @path.none? or s.path.none?
        # TODO: maybe modify depth too?
        new_path = []
        @path.each do |x|
          s.each do |path|
            new_path << x + path
          end
        end
        return Scope.new(new_path, s.depth, variables.merge(s.variables), s.default )
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
  
    def each(&block)
      @path.each(&block)
    end
  
    def humanization_key
      return self
    end
    
    Root = self.new([[]],1)
    None = self.new([],0)
    
    
  end
end