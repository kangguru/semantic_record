require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Property do
  it "should description" do
    g = SemanticRecord::Base.new("http://knowledge.erco.com/properties#LED_daylight_white_1.7W")
    
    
    #raise g.erco_hasTypeFamily.rdfs_label.inspect
  end
end