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
# A source lets you lookup,store and load data needed for humanization.
class Source
  
  def initialize(data = {})
    @source = data
    @sync = Sync.new
    @loaded = Set.new
  end
  
#
# Loads a data-file or a dir of data-files.
#
# @param [String] path to a dir or file
# @option opts [Scope] :scope the root scope, where the loaded data will be stored ( default: L )
# @option opts [String] :grep a grep to be used when a dir is given ( default: '**/*.*' )
# @return self
  def load(path,opts ={})
    options = {:scope => Scope::Root, :grep => '**/*.*'}.update(opts)
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

# Stores the given data on the base.
# @param [Object] data
# @see #store
  def <<(data)
    store([],data)
  end

# This is method which will help you loading data once.
# It will load every package just one time.
# == Example
#  source = Source.new
#  10.times do
#    source.package('base') do |s|
#      s << {:base => { :data => 'more data'}} # <= This data will be only loaded once!
#    end
#  end
#
# @param [String] package name
# @yields
# @yieldparam [Source] self
  def package(name)
    return nil if @loaded.include? name
    @sync.synchronize(Sync::EX){
      return nil if @loaded.include? name
      yield(self)
      @loaded << name
    }
  end

# Retrieves data
# @param [Scope, #each] scope a scope containing the paths to search for
# @return [String, Object, nil] data
  def get(scope, default = nil)
    scope.each do |path|
      result = find(path, @source)
      return result unless result.nil?
    end
    return default
  end

# Stores data at the path
# @param [Array] path a path to store the data at
# @param [Object] data the data to store
  def store(path ,data)
    store!(path, data)
  end
  
protected
  
  def store!(path ,str, hsh = @source)
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
          hshc = find(hshc, @source)
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