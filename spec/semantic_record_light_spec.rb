require File.dirname(__FILE__) + '/spec_helper'

SemanticRecord::Base.init({:uri => "http://localhost:8080/openrdf-sesame",:repo => "study-stash"})

describe SemanticRecord::Base do
  it "should description" do
    # ugly hack, can't be right  
    SemanticRecord::Base.init({:uri => "http://localhost:8080/openrdf-sesame",:repo => "erco"})
    #raise SemanticRecord::Base.location.inspect
    SemanticRecord::Base.construct_classes
    
    g = Emanon.new
    
    #raise Emanon.base_uri.inspect
  end
end


describe Leuchte do
    it "should respond to methods specific to lights" do
      # ugly hack, can't be right
      SemanticRecord::Base.init({:uri => "http://localhost:8080/openrdf-sesame",:repo => "erco"})
      Leuchte.should_not respond_to("query")
      Leuchte.should respond_to("find_by_hatAusstrahlwinkel")

      g = Leuchte.find(:all).first
      g.should respond_to("hatAusstrahlwinkel")
    end
end
