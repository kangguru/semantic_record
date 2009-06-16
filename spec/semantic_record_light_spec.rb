require File.dirname(__FILE__) + '/spec_helper'

describe SemanticRecord::Base do
  before(:each) do
    SemanticRecord::Base.init({:uri => "http://localhost:8080/openrdf-sesame",:repo => "erco"})
  end
  

  it "should description" do
    SemanticRecord::Base.construct_classes
    g = Emanon.new    
    g.should respond_to("has_reflector")
  end
end


describe Leuchte do
    it "should description" do
      w = WorkStation.find(:all)
      
      w.size.should eql(4)
    end
  
    it "should respond to methods specific to lights" do
      Leuchte.should_not respond_to("query")
      Leuchte.should respond_to("find_by_has_reflector")
    end
    
    it "should respond to methods specific to instances of lights" do
      g = Leuchte.find(:all)
      g[1].should respond_to("has_reflector")
      g[1].attributes['has_reflector']['type'].should eql('uri')
      g[1].has_reflector.should be_an_instance_of(Array)
      g[1].has_reflector.first.should eql("http://knowledge.erco.com/properties#flood_reflector")
    end
    
    it "should set variables correctly" do
#      g = Leuchte.find(:first).first
#      g.has_ray_angle="http://knowledge.erco.com/properties#narrow"
#      g.has_ray_angle.should eql(['http://knowledge.erco.com/properties#narrow'])
    end
end
