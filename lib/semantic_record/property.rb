module SemanticRecord
  class Property < Base
    def possible_values
      g = SemanticRecord::ResultParserJson.hash_values(self.class.find_by_sparql("SELECT ?property_name WHERE { ?o  <#{uri}> ?property_name}"))
      g.keys
    end
    
    def some_method
      g = self.class.find_by_sparql("DESCRIBE <#{uri}>")
      raise g.inspect
    end
    
    def self.uri
      "http://www.w3.org/2002/07/owl#ObjectProperty"
    end
  end  
end