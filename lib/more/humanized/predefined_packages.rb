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

module PredefinedPackages
  
  def predefined_packages
    @predefined_packages ||= {}
  end
  
  def define(name, &block)
    raise ArgumentError, "define requires a block" unless block_given?
    @sync.synchronize(Sync::EX){
      if predefined_packages.key? name
        raise ArgumentError, "Package  already defined: '#{name}'"
      end
      predefined_packages[name] = block
    }
  end
  
  def use(*names)
    unloadeable = []
    names.each do |name|
      if predefined_packages.key? name
        package(name) do
          self.instance_eval( &predefined_packages[name] )
        end
      else
        unloadeable << name
      end
    end
    if unloadable.any?
      raise ArgumentError, "Trying to load undefined packages: '#{unloadable.join ', '}'"
    end
    return self
  end
  
end

end