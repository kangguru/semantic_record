require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Base do
  it "should get the specific attribute to uri" do
    inst = SemanticRecord::Base.find_by_sparql('SELECT ?result WHERE { ?result <http://www.w3.org/2000/01/rdf-schema#label> "LarsBrillert"}')


    inst.first.attribute("http://www.w3.org/2000/01/rdf-schema#label")[:value].should include("LarsBrillert")

    inst.first.attribute("http://www.w3.org/2000/01/rdf-schema#label")[:range].uri.to_s.should eql("http://www.w3.org/2000/01/rdf-schema#Literal")

    inst.first.attribute("http://www.w3.org/2000/01/rdf-schema#label")[:domain].uri.to_s.should eql("http://www.w3.org/2000/01/rdf-schema#Resource")

  end  

  it "should get resource from remote" do
    tim = SemanticRecord::Base.new("http://dbpedia.org/resource/Tim_Berners-Lee")
    
#    raise tim.rdfs_label(:lang => :de).inspect

    tim.dbpedia_birthPlace.first.uri.should eql("http://dbpedia.org/resource/London")
    
    #tim.attribute("http://dbpedia.org/ontology/Person/birthPlace")[:value].first.uri.should eql("http://dbpedia.org/resource/London")
  end
end
