require File.dirname(__FILE__) + '/spec_helper'


describe TripleManager do
  it "should have a transitmodl" do
    #TripleManager.transit_model.should_be kind_of? Redland::Model
  end
  
  it "should describe a resource" do
    TripleManager.describe("http://www.medieninformatik.fh-koeln.de/miwiki/Spezial:URIResolver/Philipp_Ohliger")
  end
  
  it "should find triples in transit model" do
    TripleManager.add("http://example.org","http://www.w3.org/1999/02/22-rdf-syntax-ns#type","http://example.org#example")
    
    TripleManager.exists_as_subject?("http://example.org").should be true
  end
    
  
  
  
end