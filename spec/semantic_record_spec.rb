require File.dirname(__FILE__) + '/spec_helper'


describe SemanticRecord do

  it do
    SemanticRecord::Base.should_not respond_to("construct_attributes")
  end
  
end

describe Genre do
  # after(:each) do
  #   @g.remove!("http://musicbrainz.org/tempo")
  # end
  
  it "should respond to various methods" do
    Genre.should_not respond_to("query")
    Genre.should respond_to("construct_attributes","find_by_sparql","find","find_by_artist",'location=','repository=')
  end
  
  it "should not respond to unknown methods" do
    Genre.should_not respond_to("const")
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
    
    Genre.attributes.to_optional_clause.should eql("OPTIONAL { ?uri <http://example.org/music/altesProp> ?altesProp. } OPTIONAL { ?uri <http://example.org/music#neuesProp> ?neuesProp. }")
  end

  it "should have an empty optional properties clause" do
    Genre.stub!(:attributes).and_return({})
    
    Genre.attributes.to_optional_clause.should eql("")    
  end
  
  it "should have methods called artist,neuesProp,name " do
    t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"uri\", \"name\", \"neuesProp\", \"artist\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"uri\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Funk\" }, \n\t\t\t\t\"artist\": { \"type\": \"literal\", \"value\": \"Jon\" }, \n\t\t\t\t\"neuesProp\": { \"type\": \"literal\", \"value\": \"test\" }\n\t\t\t}, \n\t\t\t{\n\t\t\t\t\"uri\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Rock\" }, \n\t\t\t\t\"name\": { \"type\": \"literal\", \"value\": \"poppig\" }\n\t\t\t}\n\t\t]\n\t}\n}"
    Genre.stub!(:find_by_sparql).and_return(t) 
    genres = Genre.find(:all)
    
    genres[0].should respond_to("artist","neuesProp","name","artist=","neuesProp=","name=")
    genres[1].should respond_to("artist","neuesProp","name","artist=","neuesProp=","name=")    
  end
  
  it "should return an array of objects" do   
    t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"uri\", \"name\", \"neuesProp\", \"artist\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"uri\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Funk\" }, \n\t\t\t\t\"artist\": { \"type\": \"literal\", \"value\": \"Jon\" }, \n\t\t\t\t\"neuesProp\": { \"type\": \"literal\", \"value\": \"test\" }\n\t\t\t}, \n\t\t\t{\n\t\t\t\t\"uri\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Rock\" }, \n\t\t\t\t\"name\": { \"type\": \"literal\", \"value\": \"poppig\" }\n\t\t\t}\n\t\t]\n\t}\n}"
    Genre.stub!(:find_by_sparql).and_return(t) 
    genres = Genre.find(:all)
    
    genres.size.should ==(2)
    genres.should be_an_instance_of(Array)
    genres[0].should be_an_instance_of(Genre)
    genres[0].uri.should eql("http://example.org/music#Funk")
    genres[1].should be_an_instance_of(Genre)
    genres[1].uri.should eql("http://example.org/music#Rock")
    
    funk = Genre.find(:first)
    funk.first.uri.should eql("http://example.org/music#Funk")
    
    rock = Genre.find(:last)
    rock.first.uri.should eql("http://example.org/music#Rock")
  end
  
  it "should raise an error if massasignment with unknown attribute" do
    house = Genre.new
    lambda { house.attributes={'invalid_accessor'=>'drum party'} }.should raise_error(NoMethodError)
  end
  
  it "should find Jazz by Jon" do
    g = Genre.find_by_artist("Jon")
#    raise g.inspect
    g.first.artist.should eql("Jon")
    g.first.uri.should eql("http://example.org/music#Jazz")
  end
  
  it "should not raise an error, if nothing is found" do
    g = Genre.find_by_artist("Jonny").first
    g.should be_nil
  end
    
  it "should have exact 1 instance of genre with uri http://example.org/music#Jazz" do
    t = "{\n\t\"head\": {\n\t\t\"vars\": [ \"uri\", \"name\", \"neuesProp\", \"artist\" ]\n\t}, \n\t\"results\": {\n\t\t\"bindings\": [\n\t\t\t{\n\t\t\t\t\"uri\": { \"type\": \"uri\", \"value\": \"http:\\/\\/example.org\\/music#Funk\" }, \n\t\t\t\t\"artist\": { \"type\": \"literal\", \"value\": \"Jon\" }, \n\t\t\t\t\"neuesProp\": { \"type\": \"literal\", \"value\": \"test\" }\n\t\t\t}]\n\t}\n}"
    Genre.stub!(:find_by_sparql).and_return(t)

    jazz = Genre.find("http://example.org/music#Funk")
    jazz.size.should ==(1)
    jazz[0].should be_an_instance_of(Genre)
    jazz[0].uri.should eql("http://example.org/music#Funk")
  end

  it "should raise an ArgumentError if invalid symbol" do
    lambda {Genre.find(:test)}.should raise_error(ArgumentError)    
  end

  it "should raise an MALFORMED QUERY exception if uri is invalid" do
  #  lambda {Genre.find('invalid')}.should raise_error(RubySesame::SesameException)
  end
  
  it "should update and restore" do
    g = Genre.find(:first)[0]
    g.artist="John Doo"
    g.save
    
    g = Genre.find_by_artist("John Doo")[0]
    g.artist.should eql("John Doo")
    g.artist="Jon"
    g.save

    g = Genre.find_by_artist("Jon")[0]
    g.should_not be_nil
  end
  
  it "should add a triple an extend the schema" do
    @g = Genre.find(:first)[0]
    @g.add!("http://musicbrainz.org/tempo","slow")
    #
    #raise @g.class.attributes.inspect
    
    @g.tempo.should eql("slow")
    # drop this attribute, should be handled via after-directive     
    @g.remove!("http://musicbrainz.org/tempo")
  end
  
end