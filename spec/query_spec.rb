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

describe Humanized::Query do
  
  it "should be awesome" do
    
    s = Humanized::Query.new
    (s.a | s.b).should == Humanized::Query.new([[:a],[:b]])
    
    s._{ a | b }.should == Humanized::Query.new([[:a],[:b]])
    
    s._(:a,Testing::User).should == Humanized::Query.new([[:a,:testing,:user]])
    
  end
  
  it "query._ should equal query" do
    
    s = Humanized::Query.new
    
    s._.should == s
    
    s.humanization_key.should == s
    
  end
  
  describe "hashes" do
    
    it "should translate hashes to options" do
      
      h = {:x => 'y'}
      
      h._.variables.should == h
      
    end
    
    it "should dup variables" do
      
      h = {:x => 'y'}
      
      q = h._
      
      h[:x] = 'z'
      
      q.variables.should_not == h
      
    end
    
    it "should be consistent" do
      
      hash = {:x => 'y'}
      query = Humanized::Query.new([[:nuke]])
      result = Humanized::Query.new([[:nuke]]).with_variables({:x => 'y'})
      
      query._(hash).should == result
      query._(hash._).should == result
      (query._ + hash._).should == result
      
      hash._(query).should == result
      (hash._ + query._).should == result
      
    end
     
    it "should respect if hash subclasses do not want to be variables" do
      
      class ScepticHash < Hash
        
        def humanized_variables?
          false
        end
        
      end
      
      h = ScepticHash.new
      h[:x] = 'y'
      
      h._.should == Humanized::Query.new([[:sceptichash, :instance],[:hash, :instance],[:sceptichash],[:hash]]).with_variables(:self=>h)
      
      h._.variables.should == {:self => h}
      
    end
    
  end
  
  it "should support optional elements" do
    
    s = Humanized::Query.new([[:mandatory]]).optional?
    
    s.should == Humanized::Query.new([[:mandatory,:optional],[:mandatory]],2)
    
    Humanized::Query.new[:to_be, :not_to_be].is_the_question.should == Humanized::Query.new([[:to_be,:is_the_question],[:not_to_be,:is_the_question]])
    
  end
  
  describe "the empty query" do
    
    it "should stay empty" do
      
      Humanized::Query::None._(:x).should == Humanized::Query::None
      
    end
    
    it "should always be looked up to its default" do
      
      d = "default!"
      
      h = Humanized::Humanizer.new
      
      h[Humanized::Query::None.with_default(d)].should == d
      
    end
    
    it "should not interfere with or" do
      
      s = Humanized::Query.new([[:a,:b]])
      
      ( s | Humanized::Query::None ).should == s
      
    end
    
  end
  
end