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
require "delegate"
module Humanized
  
class Wrapper < Delegator
  
  UNWRAPPED = [:__send__ , :__id__  ,:method_missing , :respond_to? , :class, :instance_of?, :instance_eval].freeze
  
  Object.new.methods.each do |meth|
    unless UNWRAPPED.include? meth.to_sym
      undef_method meth
    end
  end
  
  def __getobj__
    @object
  end
  
  def __setobj__(obj)
    @object = obj
  end
  
  def self.wrap(*args, &block)
    a = args.flatten.map{|o|
      Wrapper.new(args,block)
    }
    return a.size == 1 ? a[0] : a
  end
  
  def initialize(object, __to_s__ = nil, &block)
    self.__setobj__(object)
    if block_given?
      @block = block
    elsif __to_s__.kind_of? String
      @block = eval("lambda{ %{#{__to_s__}} }")
    elsif __to_s__.kind_of? Array
      @block = lambda{ __to_s__[0].to_s + to_s + __to_s__[1].to_s }
    else
      raise ArgumentError, "Wrapper.initialize expects a String or a block"
    end
  end
  
  def to_s
    return @object.instance_eval(&@block)
  end
  
end

end