require 'humanized/interpolation/kng.rb'
module Humanized
module English
  
  include KNG
  
  KASUS = [
    'nominativ'.freeze,
    'genitiv'.freeze
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