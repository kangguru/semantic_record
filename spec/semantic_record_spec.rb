 require File.dirname(__FILE__) + '/spec_helper'

describe "SemanticRecord::Base" do
  before(:each) do
   @soul = Genre.new("http://soul-fantastic.com/#soul")
  end
  
  after(:each) do
    SemanticRecord::Base.base="http://example.org/music#"
#    @soul.destroy!
  end
  
  it "should mark an new instance as new_record" do    
    soul = Genre.new("http://soul-fantastic.com/#soul#{Time.now.to_i}")
    soul.new_record?.should be(true)
    
    soul.save
    
    soul.new_record?.should_not be(true)
    
  end
  
  it "should get correct values" do
    student = SemanticRecord::Base.new("http://www.medieninformatik.fh-koeln.de/miwiki/Spezial:URIResolver/Philipp_Ohliger")

    student.rdfs_label.should include("Philipp Ohliger")
  end
  
  
  it "should correctly resolve the type of an object" do
    #s = Song.new("http://example.song.com/Thriller")
    pop = Song.find
#    raise Song.uri
    types = [pop.first.rdf_type].flatten.collect {|t| t.uri}
    #raise .inspect
    

    types.should include("http://example.org/music#Song")
  end
  
  it "should expand a namespace_anchor combination to a whole uri" do
    type = :rdf_type
    
    g = SemanticRecord::Base.new("http://test.com/tester")
    
    uri = g.send(:expand,type)
    
    uri.should eql("http://www.w3.org/1999/02/22-rdf-syntax-ns#type")    
    
    base_test = :base_artist
    uri = g.send(:expand,base_test)
    
    uri.should eql("http://example.org/music#artist")    
  end
  
  it "should raise errors for invalid namespace and predicate" do
    g = SemanticRecord::Base.new("http://test.com/tester")
    
    lambda { g.send(:expand,:rdfa_type) }.should raise_error(Namespaces::NoNamespaceError)
    
    lambda { g.send(:expand,:rdf) }.should raise_error(Namespaces::NoPredicateError)
    
  end
  
  it "should be able to set and retrieve attributes" do
    
    @soul = Genre.new("http://soul-fantastic.com/#soul")
    #types = [@soul.type].flatten.collect {|t| t.uri}

    #types.should include(Genre.uri)
    
    @soul.base_artist= "Jonny Cash","John Doo"
    
    @soul.base_artist.should include("Jonny Cash","John Doo")
    
    @soul.save.should be(true)
    
    fantastic = Genre.new("http://soul-fantastic.com/#soul")
    fantastic.base_artist.should include("Jonny Cash","John Doo")
    
  
    fantastic.base_artist="Michael Jackson"
    fantastic.new_record?.should_not be(true)
    fantastic.save.should be(true)
  
    
    fantastic_soul = Genre.new("http://soul-fantastic.com/#soul")
    fantastic_soul.base_artist.should include("Michael Jackson") 
    fantastic_soul.base_artist.should_not include("John Doo") 
  end
  
  it "should save multiple values to existing object" do
    @soul.save.should be(true)
#    raise @soul.base_artist.inspect        
    @soul.base_artist = "Elvis","Shakira","Blur"

    @soul.save.should be(true)

    @soul.base_artist.should include("Shakira","Blur","Elvis")

  end
  
  it "should handle illegal base uri" do
    SemanticRecord::Base.base = "example"
    
#    lambda { g.send(:expand,:rdfa_type) }.should raise_error(Namespaces::NoNamespaceError)
    lambda { SemanticRecord::Base.find }.should raise_error(ArgumentError)
  end
  
  it "should find by generic sparql" do
    inst = SemanticRecord::Base.find_by_sparql('SELECT ?result WHERE { ?result <http://www.w3.org/2000/01/rdf-schema#label> "LarsBrillert"}')
    
    inst.size.should equal(1)
  end
  
  it "should find by dynamic finder" do
    inst = SemanticRecord::Base.find_by_rdf_type("http://www.medieninformatik.fh-koeln.de/miwiki/Spezial:URIResolver/Kategorie-3AMitarbeiter","http://www.medieninformatik.fh-koeln.de/miwiki/Spezial:URIResolver/Kategorie-3AStudent")
    inst.size.should == 4


    inst = SemanticRecord::Base.find_by_rdf_type("http://www.medieninformatik.fh-koeln.de/miwiki/Spezial:URIResolver/Kategorie-3AWPF_A")
    inst.size.should == 2
  end
  
  it "should know about equality" do
    
    @soul = Genre.new("http://soul-fantastic.com/#soul")
    @soul2 = Genre.new("http://soul-fantastic.com/#soul")
    
    @soul.should == @soul2
  
    [@soul,@soul2].uniq_by{|obj| obj.uri}.should == [@soul]  
  end
  
  
end