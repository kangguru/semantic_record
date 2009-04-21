require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::ResultParserJson do
  
  it "should description" do
    t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"property_name\", \"property_type\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"property_name\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#neuesProp\" }, \n\t\t\t\t\"property_type\": { \"type\": \"uri\", \"value\": \"http:\\/\\/www.w3.org\\/2001\\/XMLSchema#string\" }\n\t\t\t}\n\t\t]\n\t}\n}"
    #t_xml = "<?xml version='1.0' encoding='UTF-8'?> <sparql xmlns='http://www.w3.org/2005/sparql-results#'> <head> <variable name='property_name'/> <variable name='property_type'/> </head> <results> <result> <binding name='property_name'> <uri>http://example.org/music#neuesProp</uri> </binding> <binding name='property_type'> <uri>http://www.w3.org/2001/XMLSchema#string</uri> </binding> </result> </results> </sparql>"
    #result_xml = ActiveSesame::ResultParser.hash_values(t_xml)
    
    result = SemanticRecord::ResultParserJson.hash_values(t)

    result.should include("http://example.org/music#neuesProp")
    result["http://example.org/music#neuesProp"].should eql("http://www.w3.org/2001/XMLSchema#string")
    
    #result_xml.should ==(result)    
    
  end
  
  it "should description" do
    t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"instance\", \"name\", \"neuesProp\", \"artist\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"uri\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Jazz\" }, \n\t\t\t\t\"artist\": { \"type\": \"literal\", \"value\": \"Jon\" }, \n\t\t\t\t\"neuesProp\": { \"type\": \"literal\", \"value\": \"test\" }\n\t\t\t}, \n\t\t\t{\n\t\t\t\t\"instance\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Pop\" }, \n\t\t\t\t\"name\": { \"type\": \"literal\", \"value\": \"poppig\" }\n\t\t\t}\n\t\t]\n\t}\n}"
    pop = {"name"=>"poppig"}
    jazz = {"artist"=>"Jon", "neuesProp"=>"test"}
    result = SemanticRecord::ResultParserJson.parse(t)
    
    result.first.should include("uri","artist","neuesProp")
    result.first.should_not include("uri=")
 #  result.first.should include("http://example.org/music#Jazz")
    
        
 #  result["http://example.org/music#Pop"].should ==(pop)
 #  result["http://example.org/music#Jazz"].should ==(jazz)
  end
end