class Humanized::Humanizer
  
  TranslationMissing = Class.new(Exception)
  
  REGEXP=/\[([^\]]+)\]/
  VAR_PREFIX=?%
  
  NORMALIZER = lambda{|arg|
    case(arg)
      when Humanized then arg.humanization_keys
      when Array then arg.map &NORMALIZER
      when Symbol then arg.to_s
      when String then arg
      else raise ArgumentError, "don't know how to normalize #{arg}"
    end
  }
  
  def initialize
    @functions = {}
  end
  
  attr_accessor :source, :functions
  
  def humanize(*args)
    
    interpolation_args = args.last.kind_of?(Hash) ? args.pop : {}
    
    raise TranslationMissing if args.size == 0
    
    args = args.map &NORMALIZER
    
    result = lookup(args)
    
    if Hash === result
      return result
    else
      return interpolate(result,interpolation_args)
    end
  end
  
  def translate(str, *args)
    begin
      humanize(*args)
    rescue TranslationMissing
      interpolation_args = args.last.kind_of?(Hash) ? args.pop : {}
      interpolate(str,interpolation_args)
    end
  end
  
  class Iterator
    
    def initialize(path)
      @path = path
      @indices = [0] * path.size
      @max_indices = path.collect{|value|
         case(value)
           when Array then value.size
           else 1
         end
      }
      @end = false
      @value = path.collect{|value|
         case(value)
           when Array then value[0]
           else value
         end
      }
    end
    
    def next
      
      i = @indices.size
      
      result = self.get
      
      while i > 0
        i -= 1
        @indices[i] += 1
        if @indices[i] >= @max_indices[i]
          @indices[i] = 0
        else
          @value[i] = @path[i][@indices[i]]
          return result
        end
      end
      
      @end = true
      return result
    end
    
    def get
      return @value.flatten
    end
    
    def end?
      @end
    end
    
    def each
      while !end?
        yield(self.next)
      end
      return self
    end
    
  end
  
  def lookup(path)
    # example keys:
    # ['a','b'] => gets ['a']['b']
    # [['x','y'],'b'] => gets ['x']['b'] or ['y']['b']
    Iterator.new(path).each do |simple_path|
      begin
        return lookup_simple(simple_path)
      rescue TranslationMissing
      end
    end
    raise TranslationMissing
  end
  
  def lookup_simple(path)
      
      base = source
      path.each do |k|
        unless base.key? k
          raise TranslationMissing
        end
        
        base = base[k]
      end
      return base
  end
  
  def interpolate(str,vars={})
    str.gsub(REGEXP){|m|
      replace($1,vars)
    }
  end
  
  def replace(match,vars)
    spl = match.split('|')
    if spl.length == 1
      if( spl[0][0] == VAR_PREFIX )
        return vars[varname(spl[0])]
      end
    else
      fn = spl.shift
      args = spl.map do |a|
        if a[0] == VAR_PREFIX
          vars[varname(spl[0])]
        else
          a
        end
      end
      return functions[fn].call(self,args)
    end
    return spl
  end
  
  def add_function(name,&block)
    functions[name] = block
  end
  
  def varname(v)
    v[1..-1]
  end
  
end