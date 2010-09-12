class Humanized::InterpolationEnvironment
  
  UNWRAPPED_METHODS = []
  
  Object.new.methods.each do |meth|
    unless UNPROTECTED_METHODS.include? meth.to_sym
      protected meth
    end
  end
  
  
end