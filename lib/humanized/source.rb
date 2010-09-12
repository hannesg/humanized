module Humanized::Source
  
  def self.json_dir(dir)
    h = Hash.new
    
    Dir[File.join(dir,'**/*.json')].each do |file|
      path = file[dir.size..-6].split('/')
      path.shift if path.first == ''
      
      merge!(h,path,JSON.load(File.new(file)))
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