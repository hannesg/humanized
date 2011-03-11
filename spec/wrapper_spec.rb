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

Bundler.require(:default,:development)
require "humanized.rb"
require "humanized/wrapper"

describe Humanized::Wrapper do

  it "should play nice with blocks" do
    
    class User
      
      attr_accessor :name, :id
      
      def to_s
        name
      end
      
    end
    
    u = User.new
    u.id = 1234
    u.name = 'Max'
    
    w = Humanized::Wrapper.new(u) do
      "<a href=\"user?id=#{id}\">#{to_s}</a>"
    end
    
    w.to_s.should == '<a href="user?id=1234">Max</a>'
    
    w._.should == u._
    
  end

  it "should play nice with Strings" do
    
    class User
      
      attr_accessor :name, :id
      
      def to_s
        name
      end
      
    end
    
    u = User.new
    u.id = 1234
    u.name = 'Max'
    
    w = Humanized::Wrapper.new(u, '<a href="user?id=#{id}">#{to_s}</a>')
    
    w.to_s.should == '<a href="user?id=1234">Max</a>'
    
    w._.should == u._
    
  end

  it "should be stackable" do
    
    class User
      
      attr_accessor :name, :id
      
      def to_s
        name
      end
      
    end
    
    u = User.new
    u.id = 1234
    u.name = 'Max'
    
    w1 = Humanized::Wrapper.new(u, '<a href="user?id=#{id}">#{to_s}</a>')
    
    w2 = Humanized::Wrapper.new( w1 ) do
      '!' + self.to_s + '!'
    end
    
    w2.to_s.should == '!<a href="user?id=1234">Max</a>!'
    
    w2._.should == u._
    
  end


end