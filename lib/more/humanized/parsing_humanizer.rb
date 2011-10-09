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
require 'humanized/humanizer'
require 'more/humanized/parser'

module Humanized
  
class ParsingHumanizer < Humanizer
  
  component :parser do |value, old|
    
    if old.kind_of? Hash
      result = old.dup
    else
      result = {}
    end

    if value.kind_of? Hash
      result.update value
    elsif value.kind_of? Array
      value.each do |parser|
        if parser.respond_to? :provides
          parser.provides.each do |provided|
            result[provided] = parser
          end
        else
          raise ArgumentError, "A parser should respond to :provides, got #{parser.inspect}."
        end
      end
    end
    result
  end
  
  def parse(type, string, options={})
    
    options = options.dup
    options[:humanizer] = self
    options[:type] = type
    
    p = parser[type]
    
    if p.nil? 
      result = Parser::ParserMissing.new(string, options)
    else
      result = p.parse(string, options)
    end
    
    raise "Expected result to be a kind of Humanized::Parser::Result but #{result.inspect} given." unless result.kind_of? Parser::Result
    
    if block_given? and result.success?
      yield result.value
    end
    
    return result
    
  end
  
end
end