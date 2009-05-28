require 'rubygems'
require 'spec'
#require File.join(File.dirname(__FILE__), *%w[shared_ruby_sesame_spec])
require File.join(File.dirname(__FILE__), *%w[../lib/semantic_record])

# FIXME why must :repo be set? lazy behavior?
SemanticRecord::Base.init({:uri => "http://localhost:8080/openrdf-sesame",:repo => "study-stash"})

class Genre < SemanticRecord::Base
  self.base_uri="http://example.org/music#"
end

class Leuchte < SemanticRecord::Base
  self.location = {:repo => "erco"}
  self.base_uri = "http://knowledge.erco.com/products#"
end
