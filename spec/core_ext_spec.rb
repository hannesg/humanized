describe "Core Ext" do

  describe Module do
  
    it "should support strange nesting" do
    
      c = Class.new
      
      class ReallyStrange < c
      
        Nested = superclass
      
      end
      
      ReallyStrange::Nested.humanization_key.path.should == [[:reallystrange, :nested]]
      
      ReallyStrange.humanization_key.path.should == [[:reallystrange],[:reallystrange, :nested]]
    
    end
    
    it "should support self-written humanization keys" do
    
      class ClassWithOwnHumanizationKey
      
        def self.humanization_key
          Humanized::Query::Root.+(:anotherclass)
        end
        
        module Foo
        
        end
      
      end
      
      ClassWithOwnHumanizationKey.humanization_key.path.should == [[:anotherclass]]
      
      ClassWithOwnHumanizationKey::Foo.humanization_key.path.should == [[:anotherclass,:foo]]
    
    end
  
  end

end
