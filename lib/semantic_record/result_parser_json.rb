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
      
#            raise json_document.inspect
             # raise json_document.inspect
      return nil if json_document['results']['bindings'].eql? [] 
      aktuell=json_document['results']['bindings'].first['uri']['value']
      result=[]
      values=Hash.new
      initHash(json_document['results']['bindings'].first,values)
      json_document['results']['bindings'].each do |binding|  
        if !(binding['uri']['value'].eql? aktuell)
          uniqueHash values
          result << values.clone
          initHash(binding,values)
          aktuell = binding['uri']['value']
        end 
        binding.each do |b|          
          values[b[0]]['value']<<b[1]['value']
          values[b[0]]['type']=b[1]['type']
          values[b[0]]['history'] = []
        end
      end
      uniqueHash values
      result << values.clone
      

      result
    end
    
    def self.uniqueHash(hash)
      hash.each do |key,value|
        hash[key]['value']=hash[key]['value'].uniq
      end
      hash
    end
    
    def self.initHash(doc,hash)
      hash.clear
      doc.each do |var|
        hash[var[0]]={'value'=>[],'type'=>''}
      end
      hash
    end
    
    #Parses the result of a specific sparql-query that gets all instances and their attributes out of the store
    def self.parseOld(json_document)
      json_document = JSON.parse(json_document)
      raise json_document
      ary = {}
#      returning [] do |ary|
        json_document['head']['vars'].each do |var|
          a = []
          g = {var => {'type' => "",'value' => []} }
          json_document['results']['bindings'].each do |binding|
            g[var]['value'] << binding[var]['value']
            g[var]['type'] = binding[var]['type']
          end
          g[var]['value'] = g[var]['value'].uniq
          ary.merge!(g)
        end
        raise ary.inspect
        result=[ary]
    end
  end
end