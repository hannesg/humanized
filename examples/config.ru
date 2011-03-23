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

# This is an example how i18n could look for a web service using rack:

require 'rubygems'
gem 'facets'
$:.unshift File.expand_path('../lib/', File.dirname(__FILE__))
require 'humanized'

class ChooseHumanizer
  
  def initialize(app, humanizers)
    @app = app
    @humanizers = humanizers
  end
  
  def call( env )
    headers = parse_http_accept(env['HTTP_ACCEPT_LANGUAGE'] || "")
    h = @humanizers['default']
    v = 0
    @humanizers.each do |name, humanizer|
      if headers.key?(name) and headers[name] > v
        v = headers[name]
        h = humanizer
      end
    end
    
    env['humanizer'] = h
    return @app.call(env)
  end
  
  def parse_http_accept(header)
    # poor mans simple header parser
    parts = header.split(/; *q=(\d\.\d|\d) *(?:, *|$)/)
    result = {}
    parts.each_slice(2) do |names,value|
        value = value.to_f
        names.split(',').each do |splitter|
            result[splitter.strip] = value
        end
    end
    return result
  end
  
end

English = Humanized::Humanizer.new
English << {
  :hello => 'Hello %name!'
}

German = Humanized::Humanizer.new
German << {
  :hello => 'Hallo %name!'
}

French = Humanized::Humanizer.new
French << {
  :hello => 'Bon jour %name!'
}

use ChooseHumanizer, {
  "en" => English,
  "de" => German,
  "fr" => French,
  "default" => English
}

run lambda{|env|
  humanizer = env['humanizer']
  
  name = ( Rack::Request.new(env).GET['name'] || 'Jack' )
  
  response = Rack::Response.new
  response['Content-Type'] = 'text/plain'
  
  response.write( humanizer[:hello, {:name => name}])
  
  response.finish
}

