require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Support do
  before(:each) do
    @s = Song.new
  end
  
  it "should be able to reinit the tracking process" do
     @s.name="gerhard"
     @s.name="kristian"
     @s.set_name "andreas",true
     @s.name(:old).should be_nil
  end
  
  
  it "should keep track of the last 2 changes" do
    @s.should respond_to('name','name=')
    @s.name.should be_nil
    
    @s.name="gerhard"
    @s.name.should eql('gerhard')
    @s.name(:old).should be_nil
    
    @s.name="egon"
    @s.name.should eql('egon')
    @s.name(:old).should eql('gerhard')
    
    @s.name="egon"
    @s.name.should eql('egon')
    @s.name(:old).should eql('gerhard')

    @s.name="petra"
    @s.name.should eql('petra')
    @s.name(:old).should eql('gerhard')    
  end
  
  
  it "should raise an ArgumentError if invoked with unknown symbol" do
    lambda { @s.name(:invalid) }.should raise_error(ArgumentError)    
  end
  
  
end


class Song  
  attr_accessor_with_versioning :name
end