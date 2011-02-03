require "rubygems"
require "bundler/setup"

Bundler.require(:default,:development)
require "humanized.rb"
require "humanized/extras/yaml_source.rb"

describe Humanized::YamlSource do
  
  it "should load a whole dir" do
    
    h = Humanized::Humanizer.new
    h.extend(Humanized::YamlSource)
    h.load_yaml(File.join(File.dirname(__FILE__),'data/de'))
    
    h.get(:user,:female,:plural,:nominativ).should == 'Benutzerinnen'
    
  end
  
  it "should load single file" do
    
    h = Humanized::Humanizer.new
    h.extend(Humanized::YamlSource)
    h.load_yaml(File.join(File.dirname(__FILE__),'data/de/user.yml'), :user._ )
    
    h.get(:user,:female,:plural,:nominativ).should == 'Benutzerinnen'
    
  end
  
  
end