require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Property do
  it "should description" do

    g=SemanticRecord::Property.find("http://knowledge.erco.com/properties#has_color_of_light")
    g[0].possible_values.should be_kind_of(Array)
    
#    raise g[0].possible_values.inspect
  end
  
  it "should make some wonderful describing of itself" do
    
    g = SemanticRecord::Property.find("http://knowledge.erco.com/properties#has_color_of_light")
    g[0].some_method
  end
end