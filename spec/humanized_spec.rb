require "rubygems"
require "bundler/setup"
require "yaml"

Bundler.require(:default,:development)
require "humanized.rb"
require "humanized/extras/scope_parslet.rb"

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
      
      H = humanizer = Humanized::Humanizer.new( d )
      
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
