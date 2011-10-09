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

    UNCHANGED_METHODS = Set.new([:__send__,:object_id])
    PRIVATE_METHODS = Set.new([:extend,:send,:eval,:instance_exec,:instance_eval, :respond_to? ,:__id__,:method])

    class LockedDown
      public_instance_methods.each do |meth|
        if UNCHANGED_METHODS.include? meth.to_sym
          next
        elsif PRIVATE_METHODS.include? meth.to_sym
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

    PRIVATE_METHODS.each do |meth|
      class_eval(<<RB)
alias_method :real_#{meth}, #{meth.inspect}

def #{meth.to_s}(*args,&block)
  @masterkey.send(#{meth.inspect},*args,&block)
end
RB
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
    
    def inspect
      "#<#{self.class.name}:#{self.object_id.to_s}>"
    end
    
  end

end