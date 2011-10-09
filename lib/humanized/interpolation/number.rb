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

require 'facets/numeric/round.rb'

module Humanized
module Number
  
  class PartitionEnumerator
    
    include Enumerable
    
    def initialize(range, size)
      @range = range
      @size = size
    end
    def each
      i = @range.first
      size = @range.last - @range.first
      e = @range.end
      if @range.exclude_end?
          e = e - 1
      else
          size = size + 1
      end
      m = size.modulo(@size)
      if m != 0
        yield(i...(i+m))
        i = i+m
      end
      while( i <= e )
        yield(i...(i+@size))
        i = i+@size
      end
    end
  end
  
  
  def number(humanizer, number, format = 'default', precision='')
    
    if format == 'default' or format.nil?
      it = number._(:format,:default)
    else
      format = format.to_sym
      it = number._.format( format._ | :default._ )
    end
    
    if precision.kind_of? String and precision.length > 0
      precision = x_to_i(precision)
    end
    
    unless precision.kind_of? Integer
      precision = humanizer.get( it.precision , :default=>0 )
    end
    
    num = number.round_at(precision).to_s
    full, frac = num.split('.', 2)
    
    if( full.length > 3 )
      separator = humanizer.get( it.separator , :default=>'' )
      if separator.length > 0
        full = PartitionEnumerator.new(0...full.length, 3).map{|rng|
          full[rng]
        }.join(separator)
      end
    end
    
    if( precision > 0 )
      delimiter = humanizer.get( it.delimiter , :default=>'.' )
      if frac.length > precision
        frac = frac[0...precision]
      else
        frac = frac.ljust(precision, '0')
      end
      return [full, frac].join(delimiter)
    end
    
    return full
    
  end
  
end
end
