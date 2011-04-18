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

require "humanized.rb"
require "humanized/interpolation/date.rb"
require "humanized/interpolation/number.rb"

describe Humanized do
  
  module Testing
  
    class User
      
      
      
    end
    
    class Admin < User
      
    end
  
  end
  
  it "should create querys correctly" do
    
    Testing::User._.should == Humanized::Query.new([[:testing,:user]])
    Testing::Admin._.should == Humanized::Query.new([[:testing,:admin],[:testing,:user]])
    
    [Testing::User, :x]._.should == Humanized::Query.new([[:testing,:user,:x]])
    
    []._.should == Humanized::Query::None
    
    nil._.should == Humanized::Query::None
    
  end

  describe Humanized::Date do
    
     it "should translate dates" do
      
      h = Humanized::Humanizer.new
      h.interpolater.extend(Humanized::Date)
      
      t = Date.new(2010,10,18)
      
      h[Date,:format,:default] = '%Y-%m-%d'
      h[Date,:instance] = '[date|%self|%format]'
      
      h.interpolate('[date|%time]',{:time => t}).should == t.strftime('%Y-%m-%d')
      
      h[t].should == t.strftime('%Y-%m-%d')
      
      h[t, {:format => :default} ].should == t.strftime('%Y-%m-%d')
      
    end
    
    it "should translate times" do
      
      h = Humanized::Humanizer.new
      h.interpolater.extend(Humanized::Date)
      
      t = Time.mktime(2010,10,18,9,58,1)
      
      h[Time,:format,:default] = '%Y-%m-%d %H:%M:%S'
      h[Time,:instance] = '[date|%self|%format]'
      
      h.interpolate('[date|%time]',{:time => t}).should == t.strftime('%Y-%m-%d %H:%M:%S')
      
      h[t].should == t.strftime('%Y-%m-%d %H:%M:%S')
      
      h[t, {:format => :default} ].should == t.strftime('%Y-%m-%d %H:%M:%S')
      
    end
    
  end
  
  describe Humanized::Number do
    
    it "should translate numbers" do
      
      h = Humanized::Humanizer.new
      h.interpolater.extend(Humanized::Number)
      
      h[:numeric,:format,:default] = '%d'
      
      h.interpolate('[number|%n]',{:n => 2.4}).should == '2'
      
    end
    
  end
  
  describe Humanized::HasNaturalGenus do
    
    it "should raise an exception when not implemented" do
      
      class BadImplementedObject
        
        include Humanized::HasNaturalGenus
        
      end
      
      b = BadImplementedObject.new
      lambda{
        
        b.genus
        
      }.should raise_exception
      
    end
    
  end
  
end
