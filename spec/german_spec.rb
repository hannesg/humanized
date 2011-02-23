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
require "humanized/interpolation/german.rb"

describe Humanized::German do
  
  describe "n" do
    
    it "should work" do
      
      h = Humanized::Humanizer.new
      h[:one] = {
        :singular => {
          :nominativ => 'one'
        },
        :plural => {
          :nominativ => 'other'
        }
      }
      
      h.interpolater.extend(Humanized::German)
      
      h.interpolate('[n|%i|one|other]',:i => 1).should == 'one'
      h.interpolate('[n|%i|one|other]',:i => 2).should == 'other'
      
      h.interpolate('[n|%i|%thing]',:i => 1,:thing=>:one).should == 'one'
      h.interpolate('[n|%i|%thing]',:i => 2,:thing=>:one).should == 'other'
      
    end
    
  end
  
  describe "kn" do
    
    it "should work" do
      
      h = Humanized::Humanizer.new
      h[:one] = {
        :singular => {
          :nominativ => 'one',
          :genitiv => 'ones'
        },
        :plural => {
          :nominativ => 'other',
          :genitiv => 'others'
        }
      }
      
      h.interpolater.extend(Humanized::German)
      
      h.interpolate('[kn|nominativ|%i|%thing]',:i => 1,:thing=>:one).should == 'one'
      h.interpolate('[kn|nominativ|%i|%thing]',:i => 2,:thing=>:one).should == 'other'
      
      h.interpolate('[kn|genitiv|%i|%thing]',:i => 1,:thing=>:one).should == 'ones'
      h.interpolate('[kn|genitiv|%i|%thing]',:i => 2,:thing=>:one).should == 'others'
      
    end
    
  end
  
  describe "kng" do
    
    it "should work" do
      
      h = Humanized::Humanizer.new
      h[:user] = {
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
      
      h.interpolater.extend(Humanized::German)
      
      h.interpolate('[kng|nominativ|1|m|%thing]',:thing=>:user).should == 'Benutzer'
      h.interpolate('[kng|nominativ|1|f|%thing]',:thing=>:user).should == 'Benutzerin'
      
      #TODO: this doesn't really fit here:'
      h.interpolate('[kn|nominativ|1|%thing]',:thing=>User.new(:male)).should == 'Benutzer'
      h.interpolate('[kn|nominativ|1|%thing]',:thing=>User.new(:female)).should == 'Benutzerin'
      
      h.interpolate('[kng|nominativ|1|%thing|%thing]',:thing=>User.new(:male)).should == 'Benutzer'
      h.interpolate('[kng|nominativ|1|%thing|%thing]',:thing=>User.new(:female)).should == 'Benutzerin'
      
    end
    
  end
  
end