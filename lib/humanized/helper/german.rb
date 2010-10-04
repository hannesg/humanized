# -*- encoding : utf-8 -*-
module Humanized::Helper::German
  
  SINGULAR = '$singular'.freeze
  PLURAL = '$plural'.freeze
  
  NOMINATIV = '$nominativ'.freeze
  GENITIV = '$genitiv'.freeze
  DATIV = '$dativ'.freeze
  AKKUSATIV = '$akkusativ'.freeze
  
  CASES = [NOMINATIV,GENITIV,DATIV,AKKUSATIV].freeze
  
  
  def str_to_multiplicity(num)
    if num.kind_of? String
      if "singular"[0,num.length] == num
        return SINGULAR
      elsif "plural"[0,num.length] == num
        return PLURAL
      end
    end
    if str_to_integer(num) == 1
      return SINGULAR
    else
      return PLURAL
    end
  end
  
  def str_to_case(kase)
    if kase.to_i != 0
      return CASES[kase.to_i]
    else
      CASES.each do |k|
        return k if k[1,kase.length] == kase
      end
    end
    return NOMINATIV
  end
  
  def str_to_integer(str)
    if str.respond_to? :to_i
      return str.to_i
    elsif str.respond_to? :size
      return str.size
    else
      return 1
    end
  end
  
  def inflect(noun,multiplicity='1',kase=NOMINATIV)
    multiplicity = str_to_multiplicity(multiplicity)
    kase = str_to_case(kase)
    
    key = []
    
    if Array === noun
      key += noun
    else
      key << noun
    end
    key << '$cases'
    key << multiplicity
    key << kase
    
    return @humanizer.humanize(*key)
  end
  
end
