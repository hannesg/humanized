# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2011 by Hannes Georg
#
require 'sync'
module Humanized
class Source < Hash
  
  def initialize()
    @source = {}
    @sync = Sync.new
    @loaded = Set.new
  end
  
  def load(path,opts ={})
    options = {:scope => L, :grep => '**/*.*'}.update(opts)
    if File.directory?(path)
      f = File.join(path,options[:grep])
      package('grep:' + f) do
        Dir[f].each do |file|
          package('file:'+file) do
            data = self.read_file(file)
            if data
              xpath = file[path.size..(-1-File.extname(file).size)].split('/')
              xpath.shift if xpath.first == ''
              xscope = options[:scope]._(*xpath.map(&:to_sym))
              self.store(xscope.first,data)
            end
          end
        end
      end
    else
      package('file:'+path) do
        data = self.read_file(path)
        if data
          self.store(options[:scope].first,data)
        end
      end
    end
    return self
  end

  def <<(x)
    store([],x)
  end

  def package(name)
    return nil if @loaded.include? name
    @sync.synchronize(Sync::EX){
      return nil if @loaded.include? name
      yield(self)
      @loaded << name
    }
  end

  def get(it)
    it.each do |path|
      result = find(path, @source)
      return result unless result.nil?
    end
    return nil
  end
  
  def store(path ,str, hsh = @source)
    @sync.synchronize(Sync::EX){
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
    }
  end
  
protected
  
  def read_file(file)
    ext = File.extname(file)[1..-1]
    meth = "read_#{ext}".to_sym
    if self.respond_to?(meth)
      return self.send(meth,file)
    else
      warn "No reader found for #{ext}."
      return nil
    end
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
  
end
end