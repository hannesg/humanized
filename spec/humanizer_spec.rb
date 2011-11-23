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

require "stringio"
require "humanized.rb"
require "humanized/interpolation/default"
require "humanized/interpolation/number.rb"

describe Humanized::Humanizer do

  it "should be possible to renew a humanizer" do
    
    original = Humanized::Humanizer.new
    copy = original.new( :source => Humanized::Source.new )
    copy.compiler.should == original.compiler
    copy.source.should_not == original.source
    
  end
  
  describe "component" do
  
    it "should be possible to add components on subclasses" do
      
      class HumanizerA < Humanized::Humanizer
        
        component :foo do |value, old|
          value || 41
        end
        
        component :bar
        
      end
      
      original =  HumanizerA.new(:foo => 42)
      
      original.foo.should == 42
      original.bar.should be_nil
      
      copy = original.new( :source => Humanized::Source.new )
      copy.should be_a( HumanizerA )
      copy.compiler.should == original.compiler
      copy.foo.should == original.foo
      
    end
    
    it "should be possible to add delegations" do
      
      class HumanizerB < Humanized::Humanizer
        
        component :foo, :delegate => [:a]
        
        component :bar, :delegate => {:x => :y}
        
      end
      
      original =  HumanizerB.new(:foo => Struct.new(:a).new("lol"), :bar => Struct.new(:y).new("lulz"))
      
      original.foo.should_receive(:a).exactly(1).times.and_return("lol")
      original.bar.should_receive(:y).exactly(1).times.and_return("lulz")
      
      original.a.should == "lol"
      original.x.should == "lulz"
      
    end

  end
  
  describe "[]" do
    
    it "should work" do
      
data = <<YAML
---
:name :
  :genus : :male
  :singular :
    :nominativ : Name
:testing :
  :user :
    :genus : :male
    :singular :
      :nominativ : Benutzer
      :genitiv : Benutzers
    :plural :
      :nominativ : Benutzer
      :genitiv : Benutzer
YAML
      d = YAML.load(data)
      
      H = humanizer = Humanized::Humanizer.new
      H.source.package('test') do |source|
        
        source << d
        
      end
      
      class Testing::Superadmin < Testing::Admin
        
        H[_.singular] = {:nominativ=>'Superadmin'}
        H[_.plural] = {:nominativ=>'Superadmins'}
        
      end
      
      H[Testing::Superadmin._.singular.nominativ].should == 'Superadmin'
      H[Testing::Superadmin,:singular,:nominativ].should == 'Superadmin'

      a = Testing::Admin.new
      
    end
    
    
    it "should simply passthrough strings" do
      
      h = Humanized::Humanizer.new
      
      h['String'].should == 'String'
      
    end
    
    it "should format numbers" do
      
      h = Humanized::Humanizer.new
      h.interpolater << Humanized::Number
      
      h[:numeric, :instance] = '[number|%self|%format]'
      h[:numeric, :format ,:default, :separator]=','
      h[:numeric, :format ,:default]='%d'
      h[:numeric, :format ,:scientific, :precision] = 10
      
      h[2].should == '2'
      h[2, {:format => :scientific}].should == '2.0000000000'
      h[2, {:format => :weird}].should == '2'
      
      h[Math::PI].should == '3'
      h[Math::PI, {:format => :scientific}].should == '3.1415926536'
      h[Math::PI, {:format => :weird}].should == '3'
      
      h[2_000].should == '2,000'
      
      h.interpolate("a %number in a string")
      
    end
    
    it "should format true and false" do
    
      h = Humanized::Humanizer.new
      
      h[:trueclass] = 'yarp'
      h[:falseclass] = 'norp'
      
      h[true].should == 'yarp'
      h[false].should == 'norp'
    
    end
    
  end
  
  describe "interpolation" do
    
    it "should not f**k around when an interpolation fails" do
      
      h = Humanized::Humanizer.new( :logger => false )
      h.interpolater.instance_eval{
        def fail(humanizer, *args)
          raise "IEEEEKSS!"
        end
      }
      
      
      lambda{
        h.interpolate("[fail]")
      }.should_not raise_error
      
      h.interpolate("[fail]").should be_a(String)
      
    end
    
    it "should support humanizations" do
    
      h = Humanized::Humanizer.new()
      
      h.interpolater << Humanized::Default
      
      class Foo
      end
      
      h[Foo] = 'fooooo'
      
      h[' [humanize|%foo] ', :foo=>Foo.new].should == ' fooooo '
      
    
    end
    
  end
  
  
end
