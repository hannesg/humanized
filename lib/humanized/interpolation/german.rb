require 'humanized/interpolation/kng.rb'
module Humanized
module German
  
  include KNG
  
  KASUS = [
    'nominativ'.freeze,
    'genitiv'.freeze,
    'dativ'.freeze,
    'akkusativ'.freeze
  ].freeze
  
  NUMERUS = [
    'singular'.freeze,
    'plural'.freeze
  ].freeze
  
  GENUS = [
    'neutral'.freeze,
    'male'.freeze,
    'female'.freeze
  ].freeze
  
end
end