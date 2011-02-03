module Humanized
  
  class Ref < Array
    
    def inspect
      '!ref'+super
    end
    
  end
  
end