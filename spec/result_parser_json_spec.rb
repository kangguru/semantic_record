require File.dirname(__FILE__) + '/spec_helper'

describe ActiveSemantic::ResultParserJson do
  
  it "should description" do
    t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"property_name\", \"property_type\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"property_name\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#neuesProp\" }, \n\t\t\t\t\"property_type\": { \"type\": \"uri\", \"value\": \"http:\\/\\/www.w3.org\\/2001\\/XMLSchema#string\" }\n\t\t\t}\n\t\t]\n\t}\n}"
    #t_xml = "<?xml version='1.0' encoding='UTF-8'?> <sparql xmlns='http://www.w3.org/2005/sparql-results#'> <head> <variable name='property_name'/> <variable name='property_type'/> </head> <results> <result> <binding name='property_name'> <uri>http://example.org/music#neuesProp</uri> </binding> <binding name='property_type'> <uri>http://www.w3.org/2001/XMLSchema#string</uri> </binding> </result> </results> </sparql>"
    #result_xml = ActiveSesame::ResultParser.hash_values(t_xml)
    
    result = ActiveSemantic::ResultParserJson.hash_values(t)

    result.should include("http://example.org/music#neuesProp")
    result["http://example.org/music#neuesProp"].should eql("http://www.w3.org/2001/XMLSchema#string")
    
    #result_xml.should ==(result)    
    
  end
end