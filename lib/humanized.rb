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

require "humanized/scope"
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
      return humanization_key_without_genus.optionally(self.genus)
    end
    
    
  end

  class TranslationMissing < StandardError
    
    attr_reader :keys
    
    def initialize(keys)
      @keys = keys
      super("Missing Translation: #{keys.inspect}")
    end
    
  end
  
  def humanization_key!
    if self.anonymous?
      return self.superclass.humanization_key
    end
    h = self.home
    if h != Object and h.respond_to? :humanization_key
      result = h.humanization_key + self.basename.downcase.to_sym
    else
      result = Scope::Root.+(*self.name.split('::').map{|s| s.downcase.to_sym })
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
      Humanized::Scope::None
    end
  end
end