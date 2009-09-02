module SemanticRecord
  #A semantic property that has a value and a type
  class Property < Base
    def possible_values
      g = SemanticRecord::ResultParserJson.hash_values (self.class.find_by_sparql("SELECT ?property_name WHERE { ?property_name <#{uri}> ?o }"))
      g.keys
    end
    
    def self.uri
      "http://www.w3.org/2002/07/owl#ObjectProperty"
    end
    
    
  end  
end