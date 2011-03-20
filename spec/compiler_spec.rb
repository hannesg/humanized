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

require "humanized.rb"

describe Humanized::Compiler do
  
  describe "reader" do
  
    it "should work with empty strings" do
      
      c = Humanized::Compiler.new
      c.send(:read, '').should == []
      
    end
  
    it "should work with simple strings" do
      
      c = Humanized::Compiler.new
      c.send(:read, 'a simple string').should == ['a simple string']
      
    end
    
    it "should work with variables in strings" do
      
      c = Humanized::Compiler.new
      c.send(:read, 'a %variable in a string').should == ['a ',:variable,' in a string']
      
    end
    
    it "should work with methods in strings" do
      
      c = Humanized::Compiler.new
      c.send(:read, 'a [method] in a string').should == ['a ',{:method=>'method',:args=>[]},' in a string']
      
    end
    
    it "should not be confused by bad method calls" do
      
      c = Humanized::Compiler.new
      
      c.send(:read, 'a []').should == ['a []']
      c.send(:read, 'a [method').should == ['a [method']
      c.send(:read, 'a [bad method').should == ['a [bad method']
      c.send(:read, 'a [bad method]').should == ['a [bad method]']
      c.send(:read, 'a [bad|').should == ['a [bad|']
      c.send(:read, 'a [bad|method').should == ['a [bad|method']
      c.send(:read, 'a [bad|method[call]').should == ['a [bad|method[call]']
      
    end
    
    it "should not be confused with strange method calls" do
      
      c = Humanized::Compiler.new
      
      c.send(:read, 'an [empty|]').should == ['an ', {:method=>'empty',:args=>['']}]
      c.send(:read, 'a [veryempty||]').should == ['a ', {:method=>'veryempty',:args=>['','']}]
      c.send(:read, 'a [variable| %x %y %z |]').should == ['a ', {:method=>'variable',:args=>[[' ',:x,' ',:y,' ',:z,' '],'']}]

    end
    
  end
  
end