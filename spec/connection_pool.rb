require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Pool do
  it "should have no connections" do
    SemanticRecord::Pool.connections.empty?.should be true
  end
  
  it "should register new connections" do
    SemanticRecord::Pool.register( {:uri => "http://mims03.gm.fh-koeln.de:8282/openrdf-sesame",:type => :sesame, :default => true, :writable => true } )
    c = SemanticRecord::Pool.connections.first
    c.should be_an_instance_of SemanticRecord::Pool::Connection
    c.socket.should_not be nil
  end
end