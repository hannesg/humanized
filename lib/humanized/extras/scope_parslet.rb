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
require "parslet"
module Humanized
  
  module ScopeParslet
    
    class Parser < Parslet::Parser
  
      rule(:comma)      { str(',') >> space? }        
      rule(:space)      { match('\s').repeat(1) }
      rule(:space?)     { space.maybe }
      rule(:dot)        { str('.') }
      rule(:string_element) { match('[a-z]').repeat(1) }
      rule(:sub_element) { str('(') >> ( path.as(:choice) >> ( comma >> path.as(:choice) ).repeat ) >> str(')') } 
      rule(:element)    { string_element.as(:element) | sub_element.as(:choices) }
      rule(:path)       { (element >> ( dot >> element ).repeat) }
      root(:path)
    
    end
    
    class Transform < Parslet::Transform
    
      rule(:choice => simple(:choice) ){
        Scope.new([[choice]])
      }
    
      rule(:choice => sequence(:choices) ){
        Scope.new([choices])
      }
    
      rule(:element => simple(:name)){
        name.to_sym
      }
      rule({:choices => sequence(:choices)} ){
        choices.reduce(:|)
      }
      #rule( sequence(:path) ){
      #  puts path.inspect
      #  start = path.shift
      #  start._(*path)
      #}
      
    end
    
    def self.scope_from_str(str)
      p = Parser.new
      t = Transform.new
      ps = p.parse(str)
      puts ps.inspect
      ts = t.apply(ps)
      #s = ts.shift
      #tm = s._(*ts)
      puts ts.inspect
      #puts tm.inspect
      return ts
    end
    
  end
  
end