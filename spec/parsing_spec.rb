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
require "helper.rb"

require "more/humanized/parsing_humanizer"
require "more/humanized/parser/numeric"

describe Humanized::ParsingHumanizer do
  
  it "should work" do
    
    ph = Humanized::ParsingHumanizer.new :parser => [Humanized::Parser::Numeric]
    
    
    ph.source.store([:numeric, :format, :default, :separator], ",")
    ph.source.store([:numeric, :format, :default, :delimiter], ".")
    
    value = nil
    
    ph.parse(:numeric, "1,337", :pedantic => true) do |parsed|
      
      value = parsed
    
    end
    
    ph.parse(:numeric, "1,337", :pedantic => true).success{|parsed| value = parsed }
    
    puts value.inspect
    
    
    
  end
  
  
  
end

