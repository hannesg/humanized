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
module German
  
  module Articles
    
    ArticleScope = Scope::Meta.articles
    
    def a(humanizer, *args)
      Wrapper.wrap(args) do |t|
        humanizer[ArticleScope.indefinite.optionally(x_to_genus(humanizer, t))._(x_to_numerus(humanizer, t), x_to_kasus(humanizer, t))] + ' ' + t.to_s
      end
    end
    
    def the(humanizer, *args)
      Wrapper.wrap(args) do |t|
        humanizer[ArticleScope.definite.optionally(x_to_genus(humanizer, t))._(x_to_numerus(humanizer, t), x_to_kasus(humanizer, t))] + ' ' + t.to_s
      end
    end
    
    def some(humanizer, *args)
      Wrapper.wrap(args) do |t|
        humanizer[ArticleScope.partitive.optionally(x_to_genus(humanizer, t))._(x_to_numerus(humanizer, t), x_to_kasus(humanizer, t))] + ' ' + t.to_s
      end
    end
    
    def none(humanizer, *args)
      Wrapper.wrap(args) do |t|
        humanizer[ArticleScope.negative.optionally(x_to_genus(humanizer, t))._(x_to_numerus(humanizer, t), x_to_kasus(humanizer, t))] + ' ' + t.to_s
      end
    end
    
  end
  
  include Articles
  
  include KNG
  
  KASUS = [
    'nominativ'.freeze,
    'genitiv'.freeze,
    'dativ'.freeze,
    'akkusativ'.freeze
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