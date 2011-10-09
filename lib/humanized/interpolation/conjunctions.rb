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
  
module Conjunctions
  
  def and(humanizer, *args)
    args = args.flatten
    last = args.pop
    if args.size == 0
      return last.to_s
    end
    return [args.join(', '), last].join(' '+humanizer[:and]+' ')
  end
  
  def or(humanizer, *args)
    args = args.flatten
    last = args.pop
    if args.size == 0
      return last.to_s
    end
    return [args.join(', '), last].join(' '+humanizer[:or]+' ')
  end
  
end
end