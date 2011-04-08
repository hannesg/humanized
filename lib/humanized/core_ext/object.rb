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
class Object
  def humanization_key
    if self.frozen? or self.kind_of?(Float) or self.kind_of?(Fixnum)
      i = self
    else
      i = self.dup.freeze
    end
    self.class.humanization_key.optionally(:instance).with_variables({:self => i })
  end
  def _(*args,&block)
    self.humanization_key._(*args,&block)
  end
end