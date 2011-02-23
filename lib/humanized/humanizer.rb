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
require 'set'
require 'humanized/compiler.rb'
require 'humanized/source.rb'
module Humanized
# A Humanizer has one simple task: create strings!
#
# To accomplish this it needs to do three independend steps:
# * find out which string to use ( this is done by the source )
# * parse the markup in that string ( this is done by the compiler )
# * interpolate it using the given variables ( this is done by the interpolater )
# The basic idea is that you create one Humanizer for every language/dialect/locale/whatever. However these can share any of these three components.
# For example, if you want to use the same markup in every string, you only need to create one compiler and can use that in every humanizer you have.
class Humanizer
  
  # This is a simple object without public methods. You can use this as a collection for interpolation methods.
  class PrivatObject
    public_instance_methods.each do |meth|
      private meth
    end
    
    public :extend
    
  end
  
  attr_reader :interpolater, :source, :compiler
  
# Creates a new Humanizer
#
# @option components [Object] :interpolater This object which has all interpolation methods defined as public methods.
# @option components [Compiler] :compiler A compiler which can compile strings into procs. (see Compiler)
# @option components [Source] :source A source which stores translated strings. (see Source)
  def initialize(components = {})
    @interpolater = (components[:interpolater] || PrivatObject.new)
    @compiler = (components[:compiler] || Compiler.new)
    @source = (components[:source] || Source.new)
  end
  
# Creates a new Humanizer which uses the interpolater, compiler and source of this Humanizer unless other values for them were specified.
# @see #initialize
  def renew(components)
    self.class.new({:interpolater=>@interpolater,:compiler=>@compiler,:source=>@source}.update(components))
  end
  
# Creates a String from the input. This will be the most used method in application code.
# 
# @return [String]
  def [](base,*rest)
    #TODO: maybe all the special cases could be realized as
    # a simple Hash[ Class => String ] ?
    it = base._(*rest)
    
    vars = it.variables
    default = it.default
    result = @source.get(it, default)
    result = default unless result.kind_of? String
    if result.kind_of? String
      return interpolate(result,vars)
    elsif default.__id__ != result.__id__
      warn "[] should be only used for strings. For anything else use get."
    end
    return result
  end

# This is a wrapper for @source.get.
# The only thing it does additionally is converting all params into a Scope.
# @see Source#get
  def get(base,*rest)
    it = base._(*rest)
    return @source.get(it, it.default)
  end

# Stores a translation
  def []=(it, *rest)
    last = rest.pop
    @source.store(it._(*rest).first,last)
  end
  
# This is an alias for @source.package
# @see Source#package
  def package(*args,&block)
    @source.package(*args,&block)
  end
  
# This is an alias for @source.load
# @see Source#load
  def load(*args,&block)
    @source.load(*args,&block)
  end
  
# This is an alias for @source.<<
# @see Source#<<
  def <<(x)
    @source << x
  end
  
  def interpolate(str,vars={})
    @compiler.compile(str).call(self,@interpolater,vars)
  end
  
end
end
