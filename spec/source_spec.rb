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
require "date.rb"

describe Humanized::Source do
  
  it "should support hash values" do
    
    s = Humanized::Source.new
    s.store([], :a => "a" , :b => "b" )
    s.store([:a], {:x => "y" })
    s.store([:a], {:x => { :z => "z" } })
    
    s.store([], {:b=>{:x => "y" }})
    s.store([], {:b=>{:x => { :z => "z" } }})
    
    s.get([[:a]]).should == "a"
    s.get([[:a, :x]]).should == "y"
    s.get([[]]).should be_nil
    
  end
  
  
end