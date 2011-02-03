# -*- encoding : utf-8 -*-
require 'facets/array/extract_options.rb'
require 'facets/hash/deep_merge.rb'

module Humanized
class Humanizer
  
  DEFAULT_INTERPOLATER = lambda{|humanizer,str,vars| str}
  
  attr_accessor :interpolater, :source
  
  def initialize(source = {})
    @interpolater = DEFAULT_INTERPOLATER
    @source = source
  end
  
  def add_helper(mod)
    @extend.call(mod)
  end
  
  # this method will guess what a user wants (ugh)
  def object_to_s(object)
    if object.kind_of? Humanized::Message
      s = lookup( object.humanization_context + object.to_s) || object.to_s
      return interpolate(s,object.humanization_variables)
    # TODO: other primitives come here
    end

  end
  
# :x, :y , "str"
  
  alias_method :call, :object_to_s
  
  def lookup(base,*rest)
    if base.kind_of? String
      return base
    end
    it = base._(*rest)
    if it.kind_of? ScopeWithVariables
      vars = it.variables
    else
      vars = {}
    end
    result = _get(it)
    if result.kind_of? String
      return interpolate(result,vars)
    elsif result.nil?
      warn "Translation missing: #{it.inspect}."
    else
      warn "[] should be only used for strings. For anything else use get."
    end
    return result
  end
  
  def get(base,*rest)
    it = base._(*rest)
    return _get(it)
  end
  
  def _get(it)
    it.each do |path|
      result = find(path, @source)
      return result unless result.nil?
    end
    return nil
  end
  
  def write(it, str)
    store(it.humanization_key.first,str)
  end
  
  alias_method :[] , :lookup
  alias_method :[]=, :write
  
protected
  def store(path ,str, hsh = @source)
    hshc = hsh
    l = path.length - 1
    if str.kind_of? Hash
      l += 1
    end
    (0...l).each do |i|
      a = path[i]
      unless hshc.key?(a)
        hshc[a] = {}
      end
      hshc = hshc[a]
      while hshc.kind_of? Humanized::Ref
        hshc = store(hshc, str,  @source)
      end
    end
    if str.kind_of? Hash
      hshc.deep_merge!(str)
    else
      hshc[path[l]] = str
    end
    return nil
  end
  
  def find(path, hsh)
    hshc = hsh
    l = path.length - 1
    (0...l).each do |i|
      a = path[i]
      return nil unless hshc.key?(a)
      hshc = hshc[a]
      while hshc.kind_of? Humanized::Ref
        hshc = find(hshc, @source)
      end
      return nil unless hshc.respond_to? :[]
    end
    hshc = hshc[path[l]]
    while hshc.kind_of? Humanized::Ref
      hshc = find(hshc, @source)
    end
    return hshc
  end
  
  def interpolate(str,vars={})
    @interpolater.call(self, str, vars)
  end
  
end
end
