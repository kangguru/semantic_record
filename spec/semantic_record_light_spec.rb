require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Base do
  it "should description" do
    SemanticRecord::Base.construct_classes
    
    
    
    #raise Emanon.base_uri.inspect
  end
end


describe Leuchte do
    it "should respond to methods specific to lights" do
      Leuchte.should_not respond_to("query")
      Leuchte.should respond_to("find_by_hatAusstrahlwinkel")

      g = Leuchte.find(:all).first
      g.should respond_to("hatAusstrahlwinkel")
    end
end
