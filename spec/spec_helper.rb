require 'rubygems'
require 'spec'
require File.join(File.dirname(__FILE__), *%w[../lib/semantic_record])

Namespaces.register( {:base => "http://example.org/music#"} )
Namespaces.register( {:erco => "http://knowledge.erco.com/properties#"} )

SemanticRecord::Base.establish_connection("http://mims03.gm.fh-koeln.de:8282/openrdf-sesame","erco")

SemanticRecord::Base.base = "http://example.org/music#"


class Genre < SemanticRecord::Base
  
end

class Song < SemanticRecord::Base
  
end


SemanticRecord::Base.base = "http://example.org/music#"

#gg =  Genre.find

#puts gg[0].neuesProp

#g = SemanticRecord.new("http://example.org/music#Xtal")
#puts SemanticRecord::Base.namespace[:base]
#g.artist = "Jon Doo"
#puts g.rdf_type.uri