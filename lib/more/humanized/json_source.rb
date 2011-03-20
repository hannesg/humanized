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
  
module JsonSource
  
  def read_json(file)
    
    f = File.open(file)
    
    js = JsonSource.translate(Yajl::Parser.new(:symbolize_keys => true).parse( f ))
    
    f.close
    
    return js
  end
  
protected
  def self.translate( o )
    if o.kind_of? Hash
      r = {}
      o.each{|k,v| r[k] = translate(v) }
      return r
    elsif o.kind_of? Array
      return o.map{|a| translate(a)}
    elsif o.kind_of? String
      if( o[0] == ?$ )
        return o[1..-1].to_sym
      end
    end
    return o
  end
  
end
  
end