require 'yaml'
module Humanized
  
module YamlSource
  
  def load_yaml(path, scope = L)
    
    if File.directory?(path)
      Dir[File.join(path,'**/*.yml')].each do |file|
        xpath = file[path.size..-5].split('/')
        xpath.shift if xpath.first == ''
        xscope = scope._(*xpath.map(&:to_sym))
        self[xscope] = YAML.load( File.open(file) )
      end
    elsif File.file?(path)
      self[scope] = YAML.load( File.open(path) )
    end
    return self
  end
  
end
  
end