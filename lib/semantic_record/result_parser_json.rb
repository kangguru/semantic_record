module SemanticRecord
  module ResultParserJson
    require "json"
    #Parses the result of a specific sparql-query that gets all the class attributes out of the store
    def self.hash_values(json_document)
      hash = {}     
      json_document = JSON.parse(json_document)

      # mittelalter
      json_document['results']['bindings'].each do |binding|
        property_type = binding['property_type']['value'].to_s unless binding['property_type'].blank?
        property_name = binding['property_name']['value'].to_s
        hash[property_name] = property_type
      end
      
      # neuzeit
      return hash
    end
    
    #Parses the result of a specific sparql-query that gets all instances and their attributes out of the store
    def self.parse(json_document)
      json_document = JSON.parse(json_document)
      ary = {}
#      returning [] do |ary|
        json_document['head']['vars'].each do |var|
          a = []
          g = {var => {'type' => "",'value' => []} }
          json_document['results']['bindings'].each do |binding|
            g[var]['value'] << binding[var]['value']
            g[var]['type'] = binding[var]['type']
 #           a << {'type' => binding[var]['type'],'value' => }
          end
          g[var]['value'] = g[var]['value'].uniq
#          t = {var => a}
          #raise t.inspect
          ary.merge!(g)
        end
#        raise ary.inspect
        ary
 #     end
#      raise json_document.inspect
#      json_document['results']['bindings']
    end
  end
end