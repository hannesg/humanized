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
require 'parslet'
module Humanized
class Compiler
  
  class Parser < Parslet::Parser
  
    rule(:body){
      (match['a-z'].repeat.as(:id) >> (str('|') >> txt.as(:arg)).repeat)
    }
    rule(:call){
      str('[') >> body.as(:args) >> str(']')
    }
    rule(:variable){ str('%') >> match['a-z'].repeat }  
  
    rule(:plain){ match['^\[\]\|%'].repeat(1) }
  
    rule(:txt){ (plain.as(:plain) | call.as(:call) | variable.as(:variable) ).repeat(1) }
  
    root(:txt)
  
  end
  
  class Transform < Parslet::Transform
  
    rule(:plain => simple(:plain)){
      plain.inspect
    }
  
    rule(:variable => simple(:variable)){
      'variables[:'+variable.to_s[1..-1]+']'
    }
  
    rule(:id => simple(:id)) {
      id
    }
  
    rule(:arg => sequence(:arg)) {
      if arg.size == 1
        arg.first
      else
        '[' + arg.join(',') + '].join'
      end
    }
  
    rule(:args => sequence(:args)) {
      'interpolater.' + args.first + '(humanizer,' + args[1..-1].join(',') + ')'
    }
  
    rule(:args => simple(:args)) {
      'interpolater.' + args + '(humanizer)'
    }
  
    rule(:call => simple(:call)) {
      call
    }
  
  
  end
  
  class Compiled < Proc
  
    attr_accessor :str
  
    def to_s
      @str
    end
    
  end

  def initialize
    @parser = Parser.new
    @transformer = Transform.new
    @compiled = Hash.new{|hsh,x| hsh[x] = compile!(x)}
  end

  def compile(c)
    @compiled[c]
  end
  
protected
  def compile!(tree)
    str = 'Compiled.new{|humanizer,interpolater,variables| ' + @transformer.apply(:arg=>@parser.parse(tree)) +' }'
    c = eval(str)
    c.str = tree
    return c
  end

end
end