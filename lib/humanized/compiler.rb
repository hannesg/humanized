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
class Compiler
  
  class Compiled < Proc
  
    attr_accessor :str
  
    def initialize(str)
      @str = str
      super()
      return self
    end
  
    def to_s
      @str
    end
    
  end

  def initialize
    @compiled = Hash.new{|hsh,x| hsh[x] = compile!(x)}
  end

# Compiles a String into a Proc
# @param [String] str A formated String
# @return [Compiled] A Proc, which will handle interpolation.
#
  def compile(str)
    @compiled[str]
  end
protected
  
  VAR_REGEXP = /^%([a-z_]+)/
  CALL_START_REGEXP = /^\[([a-z]+)[\]\|]/
  END_REGEXP = /[\[\]%\|]/
  
  TRANSFORMER = lambda{|token|
    if token.kind_of? Array
      "[#{token.map(&TRANSFORMER).join(',')}].join()"
    elsif token.kind_of? String
      token.inspect
    elsif token.kind_of? Symbol
      "variables[#{token.inspect}]"
    elsif token.kind_of? Hash
      "interpolater.#{token[:method]}(humanizer,#{token[:args].map(&TRANSFORMER).join(',')})"
    end
  }
  
  def compile!(str)
    return eval('Compiled.new(str){|humanizer,interpolater,variables| ' + TRANSFORMER.call(read(str)) +' }')  
  end
  
  def read(str)
    result = []
    rest = str
    while( rest.size > 0 )
      token, rest = read_one(rest)
      result << token
    end
    return result
  end
  
  def read_one(str)
    return str,str if str.size == 0
    match = nil
    if str =~ VAR_REGEXP
      return $1.to_sym, str[($1.size+1)..-1]
    elsif str =~ CALL_START_REGEXP
      method = $1
      args = []
      rest = str[($1.size+1)..-1]
      while rest[0] != ?]
        arg = []
        rest = rest[1..-1]
        while rest[0] != ?| and rest[0] != ?]
          token, rest = read_one(rest)
          if rest.size == 0
            return str, ''
          end
          arg << token
        end
        if rest.size == 0
          return str, ''
        end
        if arg.size == 0
          args << ''
        elsif arg.size == 1
          args << arg.first
        else
          args << arg
        end
        
      end
      return {:method=>method,:args=>args},rest[1..-1]
    elsif match = END_REGEXP.match(str)
      if match.pre_match.size == 0
        return str[0..1], str[1..-1]
      end
      return match.pre_match, match[0] + match.post_match
    end
    return str, ''
  end

end
  
end