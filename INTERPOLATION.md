Interpolation
=========

Interpolation is a serious problem in i18n. On the one hand you need a powerfull i18n framework to create dynamic language, on the other hand you don't want to overcomplicate it, not to speek of security issues.

humanized uses a small functional programming language which is specialiced on String building. Under the hood it is compiled into a simple ruby lambda.

To test the interpolation you can simply pass a string to the "Humanizer#[]" method and it will be interpolated using the humanizer's interpolater. If you want to pass variables, simply pass a hash too. In the examples we will asume that "H" is an instance of "Humanizer".

Simple Strings
-----------
The interpolation language only uses four control characters: "[", "]", "%" and "|". Any string without these characters is simply treated as a string. So to generate "Hello World" simply do that:

    H = Humanized::Humanizer.new
    #=> "Hello World"
    H["Hello World"]

Variables
-----------
Put %<i>variable name</i> inside a string to insert a variable:

    #=> "Hello World"
    H["Hello %x", {:x => "World"} ]
    
    #=> "Hello Jack"
    H["Hello %x", {:x => "Jack"} ]

Variable names currently only contains alphabetic characters and are converted to symbols. If the passed variable is not a string, the #to_s method is called.

Calling Functions
-----------
Put [<i>function name</i>] in a string to call a function. The function name must be a simple string. Functions are simple methods defined on the interpolater.

    # returns randomly one of three names
    def H.interpolater.random(humanizer)
      # humanizer will be H in this case
      return ["John", "Jack", "Nicola"][rand(3)]
    end
    
    #=> gives "Hello John" or "Hello Jack" or "Hello Nicola" randomly
    H["Hello [random]"]

Of course you can pass parameters. The function name and parameters are delimited by the "|" character.

    # repeats "o" some times
    def H.interpolater.o(humanizer, times = 5)
      # there is a better helper form integer parsing
      # but for this example, to_i should be enough
      return "o" * times.to_i
    end
    
    #=> gives "Hellooooo"
    H["Hell[o]"]
    #=> gives "Helloooooooooo"
    H["Hell[o|10]"]
    #=> gives "Hell"
    H["Hell[o|0]"]

Note that parameter count is not checked.

Parameters themself can be variables or function calls, too.

    #=> gives "Hellooooo"
    H["Hell[o|%i]", {:i => 5} ]
  
    # repeats the given string
    def H.interpolater.repeat(humanizer, str, times = 5)
      return str.to_s * times.to_i
    end
    
    #=> gives "ooooo no " 
    H["[o|5] no "] 
    #=> gives "ooooo no ooooo no ooooo no "
    H["[repeat|[o|5] no |%i]", {:i => 3} ]

Note: Parameters are not converted to a string when they don't contain a string.

    # tells you something about x
    def H.interpolater.what(humanizer, x)
      return "it is a #{x.class} (#{x.inspect})"
    end
  
    #=> gives "it is a Fixnum (3)"
    H["[what|%i]", {:i => 3} ]
    #=> gives "it is a String (\"3 \")"
    H["[what|%i ]", {:i => 3} ]

This is necessary to pass things other than strings to functions.


What it can't do
-------------------
* defining functions
* high-order functions
* defining variables
* executing ruby code
* many more...

The interpolation language is far away from being a full featured programming language. It was neither meant to be one nor am I willing to make it one. It is specific language for a specific problem. Rather than introducing features at language level I prefer writing good interpolation methods.

Extending the Interpolater
-------------------
Extending an interpolater is pretty easy. To add a new function, simply define a mehtod of the desired name on it.
When used in an interpolation, the first parameter is always the humanizer, which is used to interpolate the string. This enables you to lookup additional things from the source.

There is already a set of modules (found in the "lib/humanized/interpolation" folder) which provide handy functions to an interpolater. There are currently helpers for english and german, but they should cover similiar languages with small customizations. I'm very interested in writing helpers for more languages. If you want to help me doing that, please contact me!

 