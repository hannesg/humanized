
Examples
-------

Trivial example:

    # create a new humanizer
    $english = Humanized::Humanizer.new
    
    $english[:hi] = "Hi"
    $english[:a_and_b] = "%a and %b"
    
    # gives: "Hi"
    puts $english[:hi]
    # gives: "x and y"
    puts $english[:a_and_b, { :a => 'x', :b => 'y } )

Working with numbers:

    # load number formating methods
    $english.interpolater.extend(Humanized::Number)
    
    # defining some formats
    $english[:numeric, :format ,:default]='%d'
    $english[:numeric, :format ,:scientific]='%e'
    
    # gives: "2"
    puts $english[2]
    # gives: "2.000000e+00"
    puts $english[2, :format => :scientific ]

Okay, let's come to the meat:

    # load all helpers for english formating methods
    $english.interpolater.extend(Humanized::English)
    
    $english[:x_jump_over_y] = "[and|[the|[kn|%x|nominativ|singular]]] [n|%x|jumps|jump] over the [kn|%y|nominativ|singular]"
    
    class Fox
      
      English[_] = {
        :singular => {
          :nominativ => "fox",
        }
      }
      
    end
    
    class Wolf
      
      English[_] = {
        :singular => {
          :nominativ => "wolf",
        }
      }
      
    end
    
    class Dog
      
      English[_] = {
        :singular => {
          :nominativ => "dog",
        }
      }
      
    end
    
    class Mouse
      
      English[_] = {
        :singular => {
          :nominativ => "mouse",
          :genitiv => "mouse's"
        }
      }
      
    end
    
    # gives: "the fox jumps over the dog"
    puts English[:x_jump_over_y, {:x => Fox.new, :y => Dog.new}]
    
    # gives: "the fox and the wolf jump over the dog"
    puts English[:x_jump_over_y, {:x => [Fox.new, Wolf.new],, :y => Dog.new}]


