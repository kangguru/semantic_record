module SemanticRecord
  module SesameAdapter
    require "ruby-sesame"
   
    @@prefixes = ["PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>",
                  "PREFIX owl: <http://www.w3.org/2002/07/owl#>",
	                "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>",
	                "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"]
    @@site = nil
    @@repository = "study-stash"
    
    def init(location)
       @@site = location[:uri]
       @@repository = location[:repo]
    end
    
    def location
      [site,repo]
    end
    
    def location=(location)
      @site = location[:uri]# if location.include?(:uri)
      @repository = location[:repo]
    end
    
    def find_by_sparql(query,infer=false)
      repository.query(@@prefixes.join(" ") + " " + query,:infer => infer )        
    end
    
    # updates data in the store      
    def update(data)
      repository.add!(data.to_s, "application/x-rdftransaction")
    end
 
 
    # FIXME method is published to outer interface
    protected
  
    def site
      @site.nil? ? @@site : @site
    end
 
    def repo
      @repository.nil? ? @@repository : @repository      
    end
 
    def repository
#      unless site.nil? || repo.nil?
        server = RubySesame::Server.new("http://localhost:8080/openrdf-sesame")
        server.repository("erco")
 #     else
  #      raise ArgumentError, "no repository and/or URI specified"
   #   end
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