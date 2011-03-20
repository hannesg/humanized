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
module Humanized
  
module Article
  
  include KNG
  
  ArticleScope = [:meta, :articles]._
  
  def a(humanizer, target, *args)
    Wrapper.wrap(target) do |t|
      humanizer[ArticleScope.unspecific.optionally(x_to_genus(humanizer, t))._(x_to_numerus(humanizer, t), x_to_kasus(humanizer, t))] + ' ' + t.to_s
    end
  end
  
  def the(humanizer, target, *args)
    Wrapper.wrap(target) do |t|
      humanizer[ArticleScope.specific.optionally(x_to_genus(humanizer, t))._(x_to_numerus(humanizer, t), x_to_kasus(humanizer, t))] + ' ' + t.to_s
    end
  end
  
end
end