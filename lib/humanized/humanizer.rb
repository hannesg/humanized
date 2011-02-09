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
require 'facets/array/extract_options.rb'
require 'facets/hash/deep_merge.rb'
require 'sync'
require 'set'
module Humanized
class Humanizer
  
  DEFAULT_INTERPOLATER = lambda{|humanizer,str,vars| str}
  
  attr_accessor :interpolater, :source
  
  def initialize(source = {})
    @interpolater = DEFAULT_INTERPOLATER
    @source = source
    @sync = Sync.new
    @files = Set.new
  end
  
  def lookup(base,*rest)
    #TODO: maybe all the special cases could be realized as
    # a simple Hash[ Class => String ] ?
    if base.kind_of? String
      return base
    elsif base.kind_of?(Time) or base.kind_of?(::Date)
      return interpolate('[date|%time|%format]',{:time => base,:format => rest})
    elsif base.kind_of? Numeric
      return interpolate('[number|%number|%format]',{:number => base,:format => rest})
    else
      it = base._(*rest)
    end
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
  
  def write(it, *rest)
    last = rest.pop
    store(it._(*rest).first,last)
  end
  
  alias_method :[] , :lookup
  alias_method :[]=, :write
  
  def load(path,opts ={})
    options = {:scope => L, :grep => '**/*.*'}.update(opts)
    f = File.join(path,options[:grep])
    @sync.synchronize(Sync::EX){
      return nil if @files.include? f
      @files << f
      options = {:scope => L, :grep => '**/*.*'}.update(opts)
      if File.directory?(path)
        Dir[f].each do |file|
          data = self.read_file(file)
          if data
            xpath = file[path.size..(-1-File.extname(file).size)].split('/')
            xpath.shift if xpath.first == ''
            xscope = options[:scope]._(*xpath.map(&:to_sym))
            self[xscope] = data
          end
        end
      else
        data = self.read_file(path)
        if data
          self[options[:scope]] = data
        end
      end
    }
    return self
  end
  
protected

  def read_file(file)
    ep = File.expand_path(file)
    return nil if @files.include? ep
    @sync.synchronize(Sync::EX){
      return nil if @files.include? ep
      @files << ep
      ext = File.extname(file)[1..-1]
      meth = "read_#{ext}".to_sym
      if self.respond_to?(meth)
        return self.send(meth,file)
      else
        warn "No reader found for #{ext}."
        return nil
      end
    }
  end

  def _get(it)
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
