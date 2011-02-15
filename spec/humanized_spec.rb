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
require "rubygems"
require "bundler/setup"
require "yaml"

Bundler.require(:default,:development)
require "humanized.rb"
require "humanized/extras/scope_parslet.rb"
require "humanized/interpolation/date.rb"
require "humanized/interpolation/number.rb"

describe Humanized do
  
  module Testing
  
    class User
      
      
      
    end
    
    class Admin < User
      
    end
  
  end
  
  it "should create scopes correctly" do
    
    Humanized(Testing::User).should == Humanized::Scope.new([[:testing,:user]])
    Humanized(Testing::Admin).should == Humanized::Scope.new([[:testing,:admin],[:testing,:user]])
    
  end
=begin
  describe Humanized::Scope do
    
    Humanized::ScopeParslet.scope_from_str('a.b.c')
    Humanized::ScopeParslet.scope_from_str('a.(b,x.e).c')
    Humanized::ScopeParslet.scope_from_str('(a.b,x.e)')
    
  end
=end
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
      :name : !seq:Humanized::Ref [:name]
YAML
      d = YAML.load(data)
      #pp d
      
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
      
      #puts H[a,:singular,:nominativ, {:x=>'Y'}]
      
      #puts Testing::Admin._(:self).inspect
      #puts Testing::Admin._.attribute(:name).inspect
      
      #puts a._.inspect
      #puts a._.attributes[:name].inspect
      
      #puts humanizer.lookup(a._.attributes(:name)).inspect

    end
    
    
    it "should simply passthrough strings" do
      
      h = Humanized::Humanizer.new
      
      h['String'].should == 'String'
      
    end
    
    it "should format numbers" do
      
      h = Humanized::Humanizer.new(:interpolater => Humanized::Interpolater.new)
      h.interpolater.extend(Humanized::Number)
      
      
      h[:numeric, :format, :default]='%d'
      h[:numeric, :format, :scientific]='%e'
      
      h[2].should == '2'
      h[2, :scientific].should == '2.000000e+00'
      h[2, :weird].should == '2'
      
    end
    
  end
  
  describe Humanized::Date do
    
    it "should translate dates" do
      
      h = Humanized::Humanizer.new(:interpolater => Humanized::Interpolater.new)
      h.interpolater.extend(Humanized::Date)
      
      t = Time.mktime(2010,10,18,9,58,1)
      
      h[t,:format,:default] = '%Y-%m-%d %H:%M:%S'
      
      h.interpolater.call(h,'[date|%time]',{:time => t}).should == t.strftime('%Y-%m-%d %H:%M:%S')
      
    end
    
  end
  
  describe Humanized::Number do
    
    it "should translate numbers" do
      
      h = Humanized::Humanizer.new(:interpolater => Humanized::Interpolater.new)
      h.interpolater.extend(Humanized::Number)
      
      h[:numeric,:format,:default] = '%d'
      
      h.interpolater.call(h,'[number|%n]',{:n => 2.4}).should == '2'
      
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
