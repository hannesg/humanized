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
class Module
  
  # Generates a {Humanized::Query query} for a Module or Class. This will be used by default by
  # this Module and by all Objects of this Class.
  def humanization_key!
    if self.anonymous?
      return self.superclass.humanization_key
    end
    h = self.home
    if h != Object and h.respond_to? :humanization_key
      result = h.humanization_key + self.basename.downcase.to_sym
    else
      result = Humanized::Query::Root.+(*self.name.split('::').map{|s| s.downcase.to_sym })
    end
    thiz = self
    if defined? thiz.superclass and self.superclass != Object
      return result | self.superclass.humanization_key
    end
    return result
  end
  
  # Like {Module#humanization_key!}, but cached.
  def humanization_key
    @humanization_key ||= humanization_key!
  end

  def _(*args,&block)
    humanization_key._(*args,&block)
  end
  
end