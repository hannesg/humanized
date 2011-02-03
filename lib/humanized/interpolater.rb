require "set"
module Humanized
  
  class Interpolater
    
    REGEXP=/\[([^\]]+)\]/
    VAR_PREFIX=?%
    
    def initialize()
      @interpolation_methods = Set.new
    end
    
    def extend(mod)
      super
      @interpolation_methods += mod.public_instance_methods.map(&:to_s)
    end
    
    def call(humanizer, str, vars)
      str.gsub(REGEXP){|m|
        replace(humanizer, $1, vars)
      }
    end
    
    def replace(humanizer, match, vars)
      spl = match.split('|')
      if spl.length == 1
        if( spl[0][0] == VAR_PREFIX )
          return vars[varname(spl[0])]
        end
      else
        fn = spl.shift
        args = spl.map do |a|
          if a[0] == VAR_PREFIX
            vars[varname(a)]
          else
            a
          end
        end
        return call_interpolation_function(humanizer, fn, args)
      end
      return spl
    end
    
    def varname(v)
      v[1..-1].to_sym
    end
    
    def call_interpolation_function(humanizer, name, args)
      if @interpolation_methods.include? name
        return self.send(name, humanizer, *args)
      else
        return '[illegal method]'
      end
    end
    
  end
  
end