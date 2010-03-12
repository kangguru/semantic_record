require File.dirname(__FILE__) + '/spec_helper'


describe SemanticRecord::Support do
  it "should retrun the last item" do
    g = ['first','mid','last']
    g.last!
    g.should eql(["last"])
  end
  
  it "should rerurn the first" do
    g = ['first','mid','last']
    g.first!
    
    g.should eql(["first"])    
  end
end