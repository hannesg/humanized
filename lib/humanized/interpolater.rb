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
  class Interpolater

    NEEDED_METHODS = Set.new([:extend,:send,:eval,:__send__,:__id__,:object_id,:method])

    class LockedDown
      public_instance_methods.each do |meth|
        if NEEDED_METHODS.include? meth.to_sym
          private meth
        else
          undef_method meth
        end
      end

      def lock!
        m = method(:send)
        class << self
          undef :lock!
        end
        return m
      end
    end

    def initialize
      @object = LockedDown.new
      @masterkey = @object.lock!
    end

    def <<(mod)
      @masterkey.call(:extend, mod)
      return self
    end

    def object; @object ; end
    
  end

end