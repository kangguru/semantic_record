require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Base do
  before(:each) do
    SemanticRecord::Base.init({:uri => "http://localhost:8080/openrdf-sesame",:repo => "erco"})
  end
  

  it "should description" do
    SemanticRecord::Base.construct_classes
    
    g = Emanon.new
    
#    raise g.hatAusstrahlwinkel.inspect
    g.should respond_to("hatAusstrahlwinkel")
  end
end


describe Leuchte do
    it "should respond to methods specific to lights" do
      Leuchte.should_not respond_to("query")
      Leuchte.should respond_to("find_by_hatAusstrahlwinkel")

      g = Leuchte.find(:all).first
      
#      raise g.hatAusstrahlwinkel.inspect
      
      g.should respond_to("hatAusstrahlwinkel")
    end
end
