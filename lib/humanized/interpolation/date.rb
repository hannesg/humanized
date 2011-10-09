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
module Date
  
  def date(humanizer, date, format = 'default')
    if format == 'default' or format.nil?
      it = date._(:format,:default)
    else
      format = format.to_sym
      it = date._.format( format._ | :default._ )
    end
    f = humanizer.get(it)
    if humanizer.respond_to? :calendar
      
      return humanizer.calendar.format( f )
      
    end
    if f.kind_of? String
      return date.strftime( f )
    end
    if humanizer.logger
      humanizer.logger.error "Unable to find Date format: #{it.inspect}."
    end
    return ''
  end
  
end
end
