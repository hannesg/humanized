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
require 'humanized/interpolation/kng.rb'
module Humanized
module English
  
  module Articles
    
    def a(humanizer, *args)
      Wrapper.wrap(args) do |t|
        fs = first_sound(humanizer, t)
        s = t.to_s
        if( fs.nil? )
          fs = guess_first_sound(s)
        end
        (fs == :vowel ? 'an' : 'a' ) + ' ' + s
      end
    end
    
    def the(humanizer, *args)
      Wrapper.wrap(args) do |t|
        'the ' + t.to_s
      end
    end
    
    def no(humanizer, *args)
      Wrapper.wrap(args) do |t|
        'no ' + t.to_s
      end
    end
    
    def some(humanizer, *args)
      Wrapper.wrap(args) do |t|
        'some ' + t.to_s
      end
    end
    
  protected
    def first_sound(humanizer, x)
      return humanizer.get( x._(:first_sound) )
    end
    
    def guess_first_sound(s)
      return :consonant
    end
    
  end
  
  include KNG
  include Articles
  
  KASUS = [
    'nominativ'.freeze,
    'genitiv'.freeze
  ].freeze
  
  NUMERUS = [
    'singular'.freeze,
    'plural'.freeze
  ].freeze
  
  GENUS = [
    'neutral'.freeze,
    'male'.freeze,
    'female'.freeze
  ].freeze
  
end
end