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
require "helper.rb"

std_calendar = false
begin
  require "std_calendar.rb"
  std_calendar = !!GregorianCalendar
rescue LoadError
end


require "humanized.rb"
require "more/humanized/uses_calendar.rb"

describe Humanized::UsesCalendar do

  class HumanizerWithCalendars < Humanized::Humanizer
  
    include Humanized::UsesCalendar
  
  end

  it "should make humanizers able to deal with a calendar argument" do
    
    pending "calendar not loaded" unless std_calendar
  
    cal = UnixCalendar.new
  
    h = HumanizerWithCalendars.new(  :calendar => cal)
    
    h.calendar.should == cal
  
    i = Humanized::Humanizer.new( Humanized::UsesCalendar, :calendar => cal )
     
    i.calendar.should == cal
    
    j = i.new( :calendar => UnixCalendar.new )
    
    puts j.calendar
    puts i.calendar
  
  end

  

end

