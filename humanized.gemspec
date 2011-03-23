Gem::Specification.new do |s|
  s.name = %q{humanized}
  s.version = "0.0.1.beta"
  s.date = %q{2011-03-23}
  s.authors = ["HannesG"]
  s.email = %q{hannes.georg@googlemail.com}
  s.summary = %q{advanced i18n for ruby}
  s.homepage = %q{http://github.com/hannesg/humanized}
  s.description = %q{Humanizes it!}
  
  s.require_paths = ["lib"]
  
  s.files = Dir.glob("lib/**/**/*")
  
  s.add_dependency "facets"
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rake'
  
end