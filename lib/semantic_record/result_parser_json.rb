module SemanticRecord
  module ResultParserJson
    require "json"
    def self.hash_values(json_document)
      hash = {}     
      json_document = JSON.parse(json_document)

      json_document['results']['bindings'].each do |binding|
        property_type = binding['property_type']['value'].to_s unless binding['property_type'].blank?
        property_name = binding['property_name']['value'].to_s
        hash[property_name] = property_type
      end
      
      return hash
    end
    
    def self.parse(json_document)
#     ary = []
#      raise json_document.inspect
      json_document = JSON.parse(json_document)
      returning [] do |ary|
        json_document['results']['bindings'].each do |binding|
          hash = {}
          binding.collect do |key|
            hash.merge!({key[0] => { 'value' => key[1]['value'],'type' => key[1]['type'] } })
          end
          ary << hash
        end
      end
#      return ary
    end
  end
end