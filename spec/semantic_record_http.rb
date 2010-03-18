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
    
    tim.dbpedia_birthPlace.first.uri.should eql("http://dbpedia.org/resource/London")
  
  end
  
  it "should description" do
    blitz = SemanticRecord::Base.new("http://www.medieninformatik.fh-koeln.de/miwiki/Spezial:URIResolver/BLITZ_-2D_kollaboratives_mobiles_multimediales_System_zur_Unterst-C3-BCtzung_von_Besprechungen")
    atts = blitz.attribute("http://www.aktors.org/ontology/portal#addresses-generic-area-of-interest")
    raise atts.inspect
  end
end
