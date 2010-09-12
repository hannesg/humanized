Gem::Specification.new do |s|
  s.name = %q{humanized}
  s.version = "0.0.1.alpha"
  s.date = %q{2010-09-01}
  s.authors = ["HannesG"]
  s.email = %q{hannes.georg@googlemail.com}
  s.summary = %q{Humanizes}
  s.homepage = %q{http://github.com/hannesg/splash}
  s.description = %q{Humanizes it!}
  
  s.require_paths = ["lib"]
  
  s.files = Dir.glob("{lib,spec}/**/**/*") + ["Rakefile"]
  
  s.add_dependency "json"
end