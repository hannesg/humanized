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
require 'set'
require 'abbrev'
require 'facets/kernel/meta_class.rb'
require "humanized/interpolation/conjunctions"
module Humanized
  
module KNG
  
  include Conjunctions
  
  def g(humanizer, genus, *args)
    if args.size == 3
      # male, female, neutral
      genus = x_to_genus(humanizer, genus)
      return [:male,:female,:neutral].zip(args).assoc(genus)[1]
    end
  end
  
  def n(humanizer, numerus, *args)
    if args.size == 2
      # singular, plural
      return args[ x_to_numerus(humanizer, numerus) == :singular ? 0 : 1 ]
    elsif args.size == 1
      return each(args) do |arg|
        humanizer.get( arg , x_to_numerus(humanizer, numerus), meta_class.const_get(:KASUS).first.to_sym)
      end
    end
  end
  
  def kn(humanizer, kasus, numerus, *args)
    if args.size == 2
      # singular, plural
      return args[ x_to_numerus(humanizer, numerus) == :singular ? 0 : 1 ]
    elsif args.size == 1
      return each(args) do |arg| 
             humanizer.get( arg, x_to_numerus(humanizer, numerus), x_to_kasus(humanizer, kasus) )
      end
    end
  end
  
  def kng(humanizer, kasus, numerus, genus,*args)
    if args.size == 2
      # singular, plural
      return args[ x_to_numerus(humanizer, numerus) == :singular ? 0 : 1 ]
    elsif args.size == 1
      return each(args) do |arg|
        k = arg._
        k = k._(x_to_genus(humanizer, genus)) | k
        humanizer.get( k, x_to_numerus(humanizer, numerus), x_to_kasus(humanizer, kasus) )
      end
    end
  end
  
protected

  def abbrev_kasus
    return @abbrev_kasus if @abbrev_kasus
    @abbrev_kasus ||= Hash[*meta_class.const_get(:KASUS).abbrev.map{|(a,b)| [a,b.to_sym]}.flatten(1)]
    @abbrev_kasus.default = meta_class.const_get(:KASUS).first.to_sym
    return @abbrev_kasus
  end
  
  def abbrev_numerus
    return @abbrev_numerus if @abbrev_numerus
    @abbrev_numerus ||= Hash[*meta_class.const_get(:NUMERUS).abbrev.map{|(a,b)| [a,b.to_sym]}.flatten(1)]
    @abbrev_numerus.default = meta_class.const_get(:NUMERUS).first.to_sym
    return @abbrev_numerus
  end
  
  def abbrev_genus
    return @abbrev_genus if @abbrev_genus
    @abbrev_genus ||= Hash[*meta_class.const_get(:GENUS).abbrev.map{|(a,b)| [a,b.to_sym]}.flatten(1)]
    @abbrev_genus.default = meta_class.const_get(:GENUS).first.to_sym
    return @abbrev_genus
  end
  
  def merge_genus(a,b)
    if a.kind_of? Set
      if b.kind_of? Set
        return a + b
      else
        return a + [b]
      end
    else
      if b.kind_of? Set
        return b + [a]
      else
        return Set.new([a,b])
      end
    end
  end
  
  def x_to_genus(humanizer, x)
    if x.kind_of? HasNaturalGenus
      return x.genus
    end
    if x.kind_of? Array
      # TODO: this is inefficient...
      # IDEA 1: plug in something like Array.of(...)
      s = Set.new
      x.each do |o|
        s = merge_genus( x_to_genus(humanizer, o) )
        if s.size == 3
          break
        end
      end
      return s
    end
    if x.kind_of? String
      return abbrev_genus[x]
    end
    genus = humanizer.get(x._(:genus))
    if genus.kind_of? Symbol
      return genus
    else
      return :neutral
    end
  end

  def x_to_kasus(humanizer, x)
    i = x.to_i
    c = meta_class.const_get :KASUS
    if i > 0 and i <= c.size
      return c[i-1].to_sym
    end
    return abbrev_kasus[x]
  end

  def x_to_numerus(humanizer, x)
    # seriously: this sucks!
    if x.kind_of? String
      return abbrev_numerus[x]
    end
    i = x_to_i(humanizer, x)
    if i
      if i == 1
        return :singular
      else
        return :plural
      end
    end
    numerus = humanizer.get(x._(:numerus))
    if numerus.kind_of? Symbol
      return numerus
    else
      return :singular
    end
  end
  
  def x_to_i(humanizer, x)
    return nil if x.kind_of?(String) and x !~ /\d+/
    unless x.respond_to? :to_i
      unless x.respond_to?(:size)
        return nil
      end
      return x.size
    end
    return x.to_i
  end
  
end
  
end