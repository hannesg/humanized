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
require "humanized/interpolation/number.rb"

describe Humanized::Humanizer do

  it "should be possible to renew a humanizer" do
    
    original = Humanized::Humanizer.new
    copy = original.renew( :source => Humanized::Source.new )
    copy.compiler.should == original.compiler
    copy.source.should_not == original.source
    
  end
  
  describe "component" do
  
    it "should be possible to add components on subclasses" do
      
      class HumanizerA < Humanized::Humanizer
        
        component :foo do |value|
          value || 41
        end
        
        component :bar
        
      end
      
      original =  HumanizerA.new(:foo => 42)
      
      original.foo.should == 42
      original.bar.should be_nil
      
      copy = original.renew( :source => Humanized::Source.new )
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
    :attributes :
      :name : !ref [name]
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
      
      h = Humanized::Humanizer.new(:interpolater => Humanized::Humanizer::PrivatObject.new)
      h.interpolater.extend(Humanized::Number)
      
      h[:numeric, :instance] = '[number|%self|%format]'
      h[:numeric, :format ,:default]='%d'
      h[:numeric, :format ,:scientific]='%e'
      
      h[2].should == '2'
      h[2, {:format => :scientific}].should == '2.000000e+00'
      h[2, {:format => :weird}].should == '2'
      
      h.interpolate("a %number in a string")
      
    end
    
  end
  
  describe "interpolation" do
    
    it "should not f**k around when an interpolation fails" do
      
      h = Humanized::Humanizer.new( :logger => false )
      i = h.interpolater
      
      def i.fail(humanizer, *args)
        raise "IEEEEKSS!"
      end
      
      lambda{
        h.interpolate("[fail]"  )
      }.should_not raise_error
      
      h.interpolate("[fail]").should be_a(String)
      
    end
    
  end
  
  
end