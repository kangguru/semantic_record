module ActiveSemantic
  module ResultParserJson
    require "json"
    def self.hash_values(json_document)
      hash = {}     
      json_document = JSON.parse(json_document)

      json_document['results']['bindings'].each do |binding|
        property_type = binding['property_type']['value'].to_s
        property_name = binding['property_name']['value'].to_s
        hash[property_name] = property_type
      end
      
      return hash
    end
  end
end