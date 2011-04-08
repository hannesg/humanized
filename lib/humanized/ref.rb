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
  
  # A Reference can be used to redirect lookups for certain paths.
  class Ref < Array
    
    if self.respond_to? :yaml_tag
      yaml_tag '!ref'
    elsif YAML
      YAML.add_builtin_type('ref') do | _ , data|
        r = Ref.new
        r.concat data
        r.map!(&:to_sym)
        r
      end
    end
    
    def inspect
      '!ref' + super
    end
    
    def encode_with(coder)
      coder.style = Psych::Nodes::Sequence::FLOW
      coder.implicit = true
      coder.tag = '!ref'
      coder.seq = self
    end
    
    def init_with(coder)
      self.concat(coder.seq)
      self.map! &:to_sym
      return self
    end
    
  end
  
end