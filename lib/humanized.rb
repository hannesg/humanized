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

# Humanized is library which really helps you create human 
# readable output.
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
  
end
require "humanized/ref"
require "humanized/humanizer"
require "humanized/scope"
Dir[File.expand_path('humanized/core_ext/*.rb', File.dirname(__FILE__))].each do |file|
  require file
end
