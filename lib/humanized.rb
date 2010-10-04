# -*- encoding : utf-8 -*-
require "set"
module Humanized
  
  DIR = File.dirname(__FILE__)
  
  autoload :Humanizer,DIR+"/humanized/humanizer"
  autoload :HumanizationHash ,DIR+"/humanized/humanization_hash"
  autoload :Source,DIR+"/humanized/source"
  autoload :Helper,DIR+"/humanized/helper"

  class Choice < SortedSet
    
    def [](key)
      # to_a is cached, so this isn't converted to an array, every hit
      to_a[key]
    end
    
    def inspect
      '{' + to_a.inspect[1..-2] + '}'
    end
    
  end
  
  class << self
    
    def included(base)
      base.extend(ClassMethods)
    end
    
  end
  
  def humanization_keys
    self.class.humanization_keys
  end
  
  module ClassMethods
    
    def humanization_keys
      return @humanization_keys if @humanization_keys
      
      @humanization_keys = Choice.new
      name = self.to_s
      
      if name[0,2] != '#<'
        
        @humanization_keys << name.split(/(?:__|::)/).map do |e|
          e.gsub(/([A-Z]+)([A-Z])/,'\1_\2').gsub(/([a-z])([A-Z])/,'\1_\2').downcase
        end
        
      end
      if superclass.respond_to? :humanization_keys
        @humanization_keys += superclass.humanization_keys
      end
      return @humanization_keys
    end
    
  end
  
  
end
