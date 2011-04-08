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
require "more/humanized/yaml_source.rb"

describe Humanized::YamlSource do
  
  it "should load a whole dir" do
    
    h = Humanized::Humanizer.new
    h.source.extend(Humanized::YamlSource)
    h.source.load(File.join(File.dirname(__FILE__),'data/de'), :grep=>'*.yml')
    
    h.get([:user,:female,:plural,:nominativ]._).should == 'Benutzerinnen'
    
  end
  
  it "should load single file" do
    
    #pending "redesign"
    
    h = Humanized::Humanizer.new
    h.source.extend(Humanized::YamlSource)
    h.source.load(File.join(File.dirname(__FILE__),'data/de/user.yml'),:query => :user._ )
    
    h.get([:user,:female,:plural,:nominativ]._).should == 'Benutzerinnen'
    
  end
  
  
end