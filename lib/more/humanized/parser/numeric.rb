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

require "bigdecimal"

module Humanized
class Parser
class NumericClass < self
  
  def parse(string, options)
    
    humanizer = options[:humanizer]
    if options.key? :default
      scope = [:numeric, :format]._[options[:format], :default]
    else
      scope = [:numeric, :format, :default]._
    end
    
    separator = humanizer.get(scope.separator)
    delimiter = humanizer.get(scope.delimiter)
    pedantic = options.fetch(:pedantic, false)
    
    result = Result.new(string, options)
    
    
    if pedantic
      regexp = Regexp.new([
          '^(-?)(\d{1,3}(?:',
          Regexp.escape(separator),
          '\d{3})?)(',
          Regexp.escape(delimiter),
          '(\d+))?$'
        ].join)
    else
      regexp = Regexp.new([
          '^(-?)([\d',
          Regexp.escape(separator),
          ']+)(',
          Regexp.escape(delimiter),
          '(\d+))?$'
        ].join)
    end
    
    m = regexp.match(string)
    
    if m.nil?
      return result
    end
    
    result.emit( BigDecimal( [ m[1], m[2].gsub(separator,''),  '.', m[4] ].join ), :precision => (m[4] ? m[4].length : 0) )
    
    return result
    
  end
  
  def provides
    return [:numeric]
  end
  
  
end

Numeric = NumericClass.new

end
end