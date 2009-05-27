require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::SesameAdapter do
  before(:each) do
    SemanticRecord::Base.init({:uri => nil, :repo => nil})
    Song.location=({:uri => nil, :repo => nil})
    Emanon.location=({:uri => nil, :repo => nil})
  end  
  
  
  it "should have a Song with nothing" do
   Song.location.should eql([nil,nil])
  end
  
  it "should have a Song with uri" do
    uri = "http://example.com"
    Song.location= { :uri => uri }
    Song.location.should eql([uri,nil])
  end

  it "should have a Song with repository" do
    SemanticRecord::Base.init({:uri => "http://singer.org"})
    repository = "erco"
    Song.location= { :repo => repository }
    Song.location.should eql(["http://singer.org",repository])
  end
  
  
  it "should have a complete Sond with uri and repository" do
    uri = "http://example.com"
    repository = "study-stash"
    Song.location= { :uri => uri,:repo => repository }
    Song.location.should eql([uri,repository])    
  end
  
  it "should handle classes from different repositories" do
    uri = "http://example.com"
    repository = "study-stash"
    repository_erco = "erco"
    Song.location= { :uri => uri,:repo => repository }
    Emanon.location= { :uri => uri,:repo => repository_erco }
    
    Song.location.should eql([uri,repository])    
    Emanon.location.should eql([uri,repository_erco])    
  end
  
  it "should have a global repository but seperate uris" do
    uri = "http://song.com"
    uri_erco = "http://erco.com"
    repository = "study-stash"
    SemanticRecord::Base.init({:repo => repository})
 
    Song.location={:uri => uri}
    Emanon.location={:uri => uri_erco}    
    
    Song.location.should eql([uri,repository])
    Emanon.location.should eql([uri_erco,repository])    
  end
  
end

class Song < SemanticRecord::Base
end

class Emanon < SemanticRecord::Base
end