# -*- encoding : utf-8 -*-
module Humanized::Source
  
  def self.json_dir(dir)
    h = Hash.new
    
    Dir[File.join(dir,'**/*.json')].each do |file|
      path = file[dir.size..-6].split('/')
      path.shift if path.first == ''
      
      if defined?(Yajl)
        merge!(h,path,Yajl::Parser.parse(File.new(file)))
      elsif defined?(JSON)
        merge!(h,path,JSON.load(File.new(file)))
      else
        raise "Please install yajl or json"
      end
    end
    
    return h
  end
  
  def self.merge!(hsh, path, otherhsh)
    current = hsh
    path.each do |key|
      unless current.key? key
        current[key]={}
      end
      current = current[key]
    end
    current.merge!(otherhsh)
    return hsh
  end
  
end
