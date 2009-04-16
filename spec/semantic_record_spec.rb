require File.dirname(__FILE__) + '/spec_helper'


describe ActiveSemantic do

  it do
    ActiveSemantic::Base.should_not respond_to("construct_attributes")
  end
  
end

describe Genre do
  it "should respond to various methods" do
    Genre.should respond_to("construct_attributes","query","find")
  end
  
  it "should have a base_uri" do
    Genre.base_uri.should eql("http://example.org/music#")
  end
  
  it "should have a rdf_type" do
    Genre.rdf_type.should eql("Genre")
  end
  
  it "should have a uri" do
    Genre.uri.should eql("http://example.org/music#Genre")
  end
  
  it "should have arguments" do
    # t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"property_name\", \"property_type\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"property_name\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#neuesProp\" }, \n\t\t\t\t\"property_type\": { \"type\": \"uri\", \"value\": \"http:\\/\\/www.w3.org\\/2001\\/XMLSchema#string\" }\n\t\t\t}\n\t\t]\n\t}\n}"
    # Genre.should_receive(:query).and_return(t)
    # Genre.construct_attributes    
    attrs = Genre.attributes
    attrs.should include("http://example.org/music#neuesProp")
    attrs["http://example.org/music#neuesProp"].should eql("http://www.w3.org/2001/XMLSchema#string")    
  end
  
  it "should have a attributes name array" do
    Genre.stub!(:attributes).and_return({ "http://example.org/music#neuesProp" => "http://www.w3.org/2001/XMLSchema#string",
                                          "http://example.org/music/altesProp" => "http://www.w3.org/2001/XMLSchema#string"})
    Genre.attributes_names.should eql(["altesProp","neuesProp"])
  end
  
  it "should have a string of sparql attributes" do
    Genre.stub!(:attributes_names).and_return(['name','age','song'])
    
    Genre.attributes_names.to_sparql_properties.should eql("?name ?age ?song")
  end
  
  it "should have a empty sparql attributes string" do
    Genre.stub!(:attributes_names).and_return([])
    
    Genre.attributes_names.to_sparql_properties.should eql("")
  end
  
  it "should have an optional properties clause" do
    Genre.stub!(:attributes).and_return({ "http://example.org/music#neuesProp" => "http://www.w3.org/2001/XMLSchema#string",
                                          "http://example.org/music/altesProp" => "http://www.w3.org/2001/XMLSchema#string"})
    
    Genre.attributes.to_optional_clause.should eql("?instance <http://example.org/music/altesProp> ?altesProp; <http://example.org/music#neuesProp> ?neuesProp")
  end

  it "should have an empty optional properties clause" do
    Genre.stub!(:attributes).and_return({})
    
    Genre.attributes.to_optional_clause.should eql("")    
  end
  
end