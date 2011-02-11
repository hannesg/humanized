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
class Humanizer
  
  class PrivatObject
    
    public_instance_methods.each do |meth|
      private meth
    end
    
  end
  
  attr_reader :interpolater, :source, :compiler
  
  def initialize(components = {})
    @interpolater = (components[:interpolater] || PrivatObject.new)
    @compiler = (components[:compiler] || Compiler.new)
    @source = (components[:source] || Source.new)
  end
  
  def renew(components)
    self.class.new({:interpolater=>@interpolater,:compiler=>@compiler,:source=>@source}.update(components))
  end
  
  def lookup(base,*rest)
    #TODO: maybe all the special cases could be realized as
    # a simple Hash[ Class => String ] ?
    if base.kind_of? String
      return base
    elsif base.kind_of?(Time) or base.kind_of?(::Date)
      return interpolate('[date|%time|%format]',{:time => base,:format => rest})
    elsif base.kind_of? Numeric
      return interpolate('[number|%number|%format]',{:number => base,:format => rest})
    else
      it = base._(*rest)
    end
    if it.kind_of? ScopeWithVariables
      vars = it.variables
    else
      vars = {}
    end
    result = @source.get(it)
    if result.kind_of? String
      return interpolate(result,vars)
    elsif result.nil?
      warn "Translation missing: #{it.inspect}."
    else
      warn "[] should be only used for strings. For anything else use get."
    end
    return result
  end
  
  def get(base,*rest)
    it = base._(*rest)
    return @source.get(it)
  end
  
  def write(it, *rest)
    last = rest.pop
    @source.store(it._(*rest).first,last)
  end
  
  alias_method :[] , :lookup
  alias_method :[]=, :write
  
# bunch of delegated methods
  
  def package(*args,&block)
    @source.package(*args,&block)
  end
  
  def load(*args,&block)
    @source.load(*args,&block)
  end
  
  def <<(x)
    @source << x
  end
  
protected
  
  def interpolate(str,vars={})
    @compiler.compile(str).call(self,@interpolater,vars)
  end
  
end
end
