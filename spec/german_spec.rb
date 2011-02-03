require "rubygems"
require "bundler/setup"
require "yaml"

Bundler.require(:default,:development)
require "humanized.rb"
require "humanized/interpolation/german.rb"

describe Humanized::German do
  
  describe "n" do
    
    it "should work" do
      
      h = Humanized::Humanizer.new
      h.source[:one] = {
        :singular => {
          :nominativ => 'one'
        },
        :plural => {
          :nominativ => 'other'
        }
      }
      
      i = Humanized::Interpolater.new
      i.extend(Humanized::German)
      
      i.call(h,'[n|%i|one|other]',:i => 1).should == 'one'
      i.call(h,'[n|%i|one|other]',:i => 2).should == 'other'
      
      i.call(h,'[n|%i|%thing]',:i => 1,:thing=>:one).should == 'one'
      i.call(h,'[n|%i|%thing]',:i => 2,:thing=>:one).should == 'other'
      
    end
    
  end
  
  describe "kn" do
    
    it "should work" do
      
      h = Humanized::Humanizer.new
      h.source[:one] = {
        :singular => {
          :nominativ => 'one',
          :genitiv => 'ones'
        },
        :plural => {
          :nominativ => 'other',
          :genitiv => 'others'
        }
      }
      
      i = Humanized::Interpolater.new
      i.extend(Humanized::German)
      
      i.call(h,'[kn|nominativ|%i|%thing]',:i => 1,:thing=>:one).should == 'one'
      i.call(h,'[kn|nominativ|%i|%thing]',:i => 2,:thing=>:one).should == 'other'
      
      i.call(h,'[kn|genitiv|%i|%thing]',:i => 1,:thing=>:one).should == 'ones'
      i.call(h,'[kn|genitiv|%i|%thing]',:i => 2,:thing=>:one).should == 'others'
      
    end
    
  end
  
  describe "kng" do
    
    it "should work" do
      
      h = Humanized::Humanizer.new
      h.source[:user] = {
        :genus => :male,
        :singular => {
          :nominativ => 'Benutzer'
        },
        :female => {
          :genus => :female,
          :singular => {
            :nominativ => 'Benutzerin'
          }
        }
      }
      
      class User < Struct.new(:genus)
        
        include Humanized::HasNaturalGenus
        
      end
      
      i = Humanized::Interpolater.new
      i.extend(Humanized::German)
      
      i.call(h,'[kng|nominativ|1|m|%thing]',:thing=>:user).should == 'Benutzer'
      i.call(h,'[kng|nominativ|1|f|%thing]',:thing=>:user).should == 'Benutzerin'
      
      #TODO: this doesn't really fit here:'
      i.call(h,'[kn|nominativ|1|%thing]',:thing=>User.new(:male)).should == 'Benutzer'
      i.call(h,'[kn|nominativ|1|%thing]',:thing=>User.new(:female)).should == 'Benutzerin'
      
      i.call(h,'[kng|nominativ|1|%thing|%thing]',:thing=>User.new(:male)).should == 'Benutzer'
      i.call(h,'[kng|nominativ|1|%thing|%thing]',:thing=>User.new(:female)).should == 'Benutzerin'
      
    end
    
  end
  
end