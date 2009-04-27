module SemanticRecord
  module SesameAdapter
    require "ruby-sesame"
    
    def self.append_features(someClass)
      
      # FIXME location is not really accessible from outside
      class << someClass
        attr_accessor :repository, :location
      end
      @@prefixes = ["PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>",
                    "PREFIX owl: <http://www.w3.org/2002/07/owl#>",
		                "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
		                "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"]
      
      
      # FIXME make repository and server accessable to outside
      def someClass.query(query)
#        server = RubySesame::Server.new("http://localhost:8080/openrdf-sesame")
        server = RubySesame::Server.new("#{location}")
        repository = server.repository("study-stash")
        repository.query(@@prefixes.join(" ") + " " + query)
      end
      
      def someClass.update(data)
        server = RubySesame::Server.new("#{location}")
        repository = server.repository("study-stash")
#        raise data.join(".").inspect
        repository.update(data.join(".") +".", "application/x-rdftransaction")
      end
      
    end    
  end
  
  
  ###  
  ##
  # FIXME use below directive to extend SemanticRecord::Base
  
  # def self.included(receiver)
  #   receiver.extend         ClassMethods
  #   receiver.send :include, InstanceMethods
  # end
end