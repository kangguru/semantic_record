require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::TransactionFactory do
  before(:each) do
    @x = SemanticRecord::TransactionFactory.new
    @s = 'http://example.org/music#Jazz'
    @p = 'http://example.org/music#artist'
    @o = 'John'
  end
  
  it "should have a transaction as root" do    
    @x.root.to_s.should eql( REXML::Element.new("transaction").to_s ) 
  end

  it "should build an arbitrary element" do
    uri = @x.send("build_element","custom")
    uri.should be_an_instance_of(REXML::Element)
    uri.to_s.should eql( REXML::Element.new("custom").to_s ) 
  end

  it "should build an uri element" do
    uri = @x.send("build_uri_element","http://example.org/music#Jazz")
    uri.should be_an_instance_of(REXML::Element)
    uri.to_s.should eql( "<uri>http://example.org/music#Jazz</uri>" ) 
  end

  it "should build an literal element" do
    uri = @x.send("build_literal_element",@o)
    uri.should be_an_instance_of(REXML::Element)
    uri.to_s.should eql( "<literal>#{@o}</literal>" ) 
  end
  
  it "should build a triple" do
    uri = @x.send("build_triple",@s,@p,@o)
  end
  
  it "should add an remove statement" do
    @x.add_remove_statement(@s, @p, @o)
    @x.to_s.should eql( "<transaction><remove><uri>#{@s}</uri><uri>#{@p}</uri><literal>#{@o}</literal></remove></transaction>" )
  end  
  
  it "should add an add statement" do
    @x.add_add_statement(@s, @p, @o)
    @x.to_s.should eql( "<transaction><add><uri>#{@s}</uri><uri>#{@p}</uri><literal>#{@o}</literal></add></transaction>" )
  end

  it "should add an update statement" do
    @new_object = "John Doo"
    @x.add_update_statement(@s, @p, @o, @new_object)
    @x.to_s.should eql( "<transaction><remove><uri>#{@s}</uri><uri>#{@p}</uri><literal>#{@o}</literal></remove><add><uri>#{@s}</uri><uri>#{@p}</uri><literal>#{@new_object}</literal></add></transaction>" )    
  end
  
  it "should create an remove transaction that removes all attributes from an resource" do
    @x.add_remove_statement(@s, nil, nil)
    @x.to_s.should eql( "<transaction><remove><uri>#{@s}</uri><null/><null/></remove></transaction>" )
  end
  
end