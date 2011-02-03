require 'abbrev'
require 'facets/kernel/meta_class.rb'
module Humanized
  
module KNG
    
  def n(humanizer, numerus, *args)
    if args.size == 2
      # singular, plural
      return args[ x_to_numerus(numerus) == :singular ? 0 : 1 ]
    elsif args.size == 1
      arg = args.first
      if arg.kind_of? String
        arg = Scope.from_str(arg)
      end
      return humanizer.get( arg , x_to_numerus(numerus), meta_class.const_get(:KASUS).first.to_sym)
    end
  end
  
  def kn(humanizer, kasus, numerus, *args)
    if args.size == 2
      # singular, plural
      return args[ x_to_numerus(numerus) == :singular ? 0 : 1 ]
    elsif args.size == 1
      arg = args.first
      if arg.kind_of? String
        arg = Scope.from_str(arg)
      end
      return humanizer.get( arg, x_to_numerus(numerus), x_to_kasus(kasus) )
    end
  end
  
  def kng(humanizer, kasus, numerus, genus,*args)
    if args.size == 2
      # singular, plural
      return args[ x_to_numerus(numerus) == :singular ? 0 : 1 ]
    elsif args.size == 1
      arg = args.first
      if arg.kind_of? String
        arg = Scope.from_str(arg)
      end
      k = arg._
      k = k._(x_to_genus(genus)) | k
      return humanizer.get( k, x_to_numerus(numerus), x_to_kasus(kasus) )
    end
  end
  
protected

  def abbrev_kasus
    return @abbrev_kasus if @abbrev_kasus
    @abbrev_kasus ||= Hash[*meta_class.const_get(:KASUS).abbrev.map{|(a,b)| [a,b.to_sym]}.flatten(1)]
    @abbrev_kasus.default = meta_class.const_get(:KASUS).first.to_sym
    return @abbrev_kasus
  end
  
  def abbrev_numerus
    return @abbrev_numerus if @abbrev_numerus
    @abbrev_numerus ||= Hash[*meta_class.const_get(:NUMERUS).abbrev.map{|(a,b)| [a,b.to_sym]}.flatten(1)]
    @abbrev_numerus.default = meta_class.const_get(:NUMERUS).first.to_sym
    return @abbrev_numerus
  end
  
  def abbrev_genus
    return @abbrev_genus if @abbrev_genus
    @abbrev_genus ||= Hash[*meta_class.const_get(:GENUS).abbrev.map{|(a,b)| [a,b.to_sym]}.flatten(1)]
    @abbrev_genus.default = meta_class.const_get(:GENUS).first.to_sym
    return @abbrev_genus
  end
  
  def x_to_genus(x)
    if x.kind_of? HasNaturalGenus
      return x.genus
    end
    i = x.to_i
    g = meta_class.const_get :GENUS
    if i > 0 and i <= g.size
      return g[i-1].to_sym
    end
    return abbrev_genus[x]
  end

  def x_to_kasus(x)
    i = x.to_i
    c = meta_class.const_get :KASUS
    if i > 0 and i <= c.size
      return c[i-1].to_sym
    end
    return abbrev_kasus[x]
  end

  def x_to_numerus(x)
    i = x.to_i
    n = meta_class.const_get :NUMERUS
    if i > 0 and i <= n.size
      return n[i-1].to_sym
    end
    return abbrev_numerus[x]
  end
    
end
  
end