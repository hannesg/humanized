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
  
class Parser
  
  class Result
  
    attr_reader :parsed_string,
                :original_string,
                :value,
                :options,
                :success
    
    def success?
      @success
    end
    
    def call
      if success?
        yield @value
      end
    end
    
    def success
      if block_given?
        yield(@value) if @success
        return self
      end
      @success
    end
    
    def failure
      if block_given?
        yield() unless success?
        return self
      end
      !success?
    end
    
    def initialize(str, options ={}, &block)
      s = str.dup.freeze
      @original_string = s
      @parsed_string = s
      @options = options
      @success = false
      if block
        instance_eval &block
      end
    end
    
    def emit(value, parsed_or_options = nil)
      @value = value
      @success = true
      if parsed_or_options.kind_of? String
        @parsed_string = parsed.dup.freeze
      elsif parsed_or_options.kind_of? Hash
        @options.update parsed_or_options
      end
      return self
    end
    
  end
  
  class ParserMissing < Result
  end
  
  def provides
    []
  end
  
  
end
  
end