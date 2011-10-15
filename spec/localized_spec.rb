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
require 'more/humanized/has_language_code'
require 'more/humanized/localized'
describe Humanized::Localized do

  class LocalizedHumanizer < Humanized::Humanizer
  
    include Humanized::HasLanguageCode
  
  end

  it "should retrieve the localized result" do
  
    de = LocalizedHumanizer.new(:language_code => "de")
    
    en = LocalizedHumanizer.new(:language_code => "en")
    
    loc = Humanized::Localized.new.update('de'=>1,'en'=>2)
    
    de[loc].should == 1
    en[loc].should == 2
  
  end

end
