require File.dirname(__FILE__) + '/spec_helper'

describe Namespaces do
  
  it "should resolve the standard namespaces" do
    Namespaces.resolve(:rdf).should eql("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    Namespaces.resolve(:rdfs).should eql("http://www.w3.org/2000/01/rdf-schema#")
    Namespaces.resolve(:owl).should eql("http://www.w3.org/2002/07/owl#")
    Namespaces.resolve(:xsd).should eql("http://www.w3.org/2001/XMLSchema#")
  end
  
  it "should raise errors on non-registered keys" do
    lambda { Namespaces.resolve(:invalid) }.should raise_error(Namespaces::NoNamespaceError)
  end

  it "should be able to register and retrieve additional namespaces" do
    Namespaces.register( {:music => "http://exaple.org/music#", "base" => "http://basecamp.org/"} )
    
    Namespaces.resolve("music").should eql("http://exaple.org/music#")
    Namespaces.resolve(:base).should eql("http://basecamp.org/")
  end
  
end