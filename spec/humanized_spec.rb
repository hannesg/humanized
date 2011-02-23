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
    
    [Testing::User, :x]._.should == Humanized::Scope.new([[:testing,:user,:x]])
    
    []._.should == Humanized::Scope::None
    
    nil._.should == Humanized::Scope::None
    
  end

  describe Humanized::Scope do
    
    it "should be awesome" do
      
      s = Humanized::Scope.new
      (s.a | s.b).should == Humanized::Scope.new([[:a],[:b]])
      
      s._{ a | b }.should == Humanized::Scope.new([[:a],[:b]])
      
      s._(:a,Testing::User).should == Humanized::Scope.new([[:a,:testing,:user]])
      
    end
    
    it "scope._ should equal scope" do
      
      s = Humanized::Scope.new
      
      s._.should == s
      
      s.humanization_key.should == s
      
    end
    
    it "should support optional elements" do
      
      s = Humanized::Scope.new([[:mandatory]]).optional?
      
      s.should == Humanized::Scope.new([[:mandatory,:optional],[:mandatory]],2)
      
      Humanized::Scope.new[:to_be, :not_to_be].is_the_question.should == Humanized::Scope.new([[:to_be,:is_the_question],[:not_to_be,:is_the_question]])
      
    end
    
    describe "the empty scope" do
      
      it "should stay empty" do
        
        Humanized::Scope::None._(:x).should == Humanized::Scope::None
        
      end
      
      it "should always be looked up to its default" do
        
        d = "default!"
        
        h = Humanized::Humanizer.new
        
        h[Humanized::Scope::None.with_default(d)].should == d
        
      end
      
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
      
      h = Humanized::Humanizer.new(:interpolater => Humanized::Humanizer::PrivatObject.new)
      h.interpolater.extend(Humanized::Number)
      
      
      h[:numeric, :format ,:default]='%d'
      h[:numeric, :format ,:scientific]='%e'
      
      h[2].should == '2'
      h[2, {:format => :scientific}].should == '2.000000e+00'
      h[2, {:format => :weird}].should == '2'
      
    end
    
  end
  
  describe Humanized::Date do
    
    it "should translate dates" do
      
      h = Humanized::Humanizer.new
      h.interpolater.extend(Humanized::Date)
      
      t = Time.mktime(2010,10,18,9,58,1)
      
      h[t,:format,:default] = '%Y-%m-%d %H:%M:%S'
      
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
