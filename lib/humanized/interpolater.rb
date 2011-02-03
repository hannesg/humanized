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
require "set"
module Humanized
  
  class Interpolater
    
    REGEXP=/\[([^\]]+)\]/
    VAR_PREFIX=?%
    
    def initialize()
      @interpolation_methods = Set.new
    end
    
    def extend(mod)
      super
      @interpolation_methods += mod.public_instance_methods.map(&:to_s)
    end
    
    def call(humanizer, str, vars)
      str.gsub(REGEXP){|m|
        replace(humanizer, $1, vars)
      }
    end
    
    def replace(humanizer, match, vars)
      spl = match.split('|')
      if spl.length == 1
        if( spl[0][0] == VAR_PREFIX )
          return vars[varname(spl[0])]
        end
      else
        fn = spl.shift
        args = spl.map do |a|
          if a[0] == VAR_PREFIX
            vars[varname(a)]
          else
            a
          end
        end
        return call_interpolation_function(humanizer, fn, args)
      end
      return spl
    end
    
    def varname(v)
      v[1..-1].to_sym
    end
    
    def call_interpolation_function(humanizer, name, args)
      if @interpolation_methods.include? name
        return self.send(name, humanizer, *args)
      else
        return '[illegal method]'
      end
    end
    
  end
  
end