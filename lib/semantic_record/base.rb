module SemanticRecord
  class Base
    include SesameAdapter

    def Base.inherited(subClass)

      ###
      ### attribute accessors that are independet from superclass
      ###
      class << self
        attr_accessor :rdf_type, :attributes, :base_uri, :attributes_names
      end
      
      attr_accessor :uri
      
      subClass.location="http://localhost:8080/openrdf-sesame"  
      subClass.repository="study-stash"
      
      subClass.base_uri="http://example.org/music#"
      subClass.rdf_type = subClass.name#.split("::").last.to_s
      subClass.attributes = {}


      def subClass.construct_attributes
        # TODO was ist wenn Namen kollidieren
        self.attributes = ResultParserJson.hash_values(self.find_by_sparql("SELECT DISTINCT ?property_name ?property_type WHERE { { ?property_name rdfs:domain <#{uri}>  } UNION {?s rdf:type <#{uri}>; ?property_name ?o. } OPTIONAL { ?property_name rdfs:range ?property_type.}  }"))
      end
      
      def subClass.construct_methods
        attr_accessor_with_versioning *(attributes_names) unless attributes_names.empty?        
        
        attributes.each do |key,value|
          self.class_eval("def self.find_by_#{key.to_human_name} (val)
           instances_result = ResultParserJson.parse(self.find_by_sparql(\"SELECT ?uri #{attributes_names.to_sparql_properties} WHERE {?uri <#{key}> '\#{val}' #{attributes.to_optional_clause} } \"))
           build(instances_result) end") 
        end
      end 

      def subClass.uri
        # TODO change my name
        "#{base_uri}#{rdf_type}"
      end
      
      #Searches the triple Store with different options
      # 1. Scope
      # * [:all] -> search for all Instances of a particular class
      # * [:first] -> search for the first Instance of a particular class
      # * [:last] -> search for the last Instance of a particular class
      # 2. Uri
      # * [uri] -> searches for an instance with the given URI
      def subClass.find(uri_or_scope)
        if uri_or_scope.kind_of?(Symbol)          
          instances_result = ResultParserJson.parse(self.find_by_sparql("SELECT ?uri #{attributes_names.to_sparql_properties} WHERE { ?uri rdf:type <#{uri}> #{attributes.to_optional_clause} }") )
          case uri_or_scope
           when :all
             instances_result = instances_result
           when :first
             instances_result.first!
           when :last
             instances_result.last!
           else raise ArgumentError, "Not knowing how to deal with this access symbol!"
          end
        elsif uri_or_scope.kind_of?(String)
          #--
          # TODO non-uri handling
          #++
          uri_to_search = URI.parse(uri_or_scope)
          instances_result = ResultParserJson.parse(self.find_by_sparql("SELECT ?uri #{attributes_names.to_sparql_properties} WHERE { ?uri rdf:type <#{uri}> #{attributes.to_optional_clause} FILTER (?uri = <#{uri_to_search.to_s}>) }") )
        end
        
        build(instances_result)
        
      end
      
      def subClass.build(instances_result)
        returning [] do |instances|        
          instances_result.each {|k|
            instances << new(k)
          }        
        end        
      end
      
      # Generates an array with all attribute-names without their namespace
      def subClass.attributes_names
        attributes.keys.collect {|key|
          key.to_human_name
        }
      end

      ###
      ### class initializer calls
      ###

      subClass.construct_attributes
      subClass.construct_methods
    end
    
    #--
    #FIXME perform a real update! implement instaniation of new resource
    #++
    # Saves all attributes to the Sesame Triple Store
    def save
      transaction_doc = SemanticRecord::TransactionFactory.new
      self.class.attributes.keys.each do |key|
          value_new = self.send(key.to_human_name)
          value = self.send(key.to_human_name,:old)
          # TODO: 
          transaction_doc.add_update_statement(uri,key,value,value_new) unless value.blank?
#          triple << "<uri>#{uri}</uri> <uri>#{key}</uri> <literal>#{value}</literal> " unless value.blank?
      end
      
      # FIXME very dirty hack for preventing datatype properties
#      triple.delete_at(0)
#      raise triple.inspect
      SemanticRecord::Base.update(transaction_doc)
    end
    
    def attributes_uri
      
    end
    
    # Sets all the Values for a Object
    def attributes=(values)
      values.each do |key,value|
          self.send(key.to_s + "=",value)
      end      
    end
    
    # Creates a new Object with the attributes and their values in the values-Hash
    def initialize(values={})      
      self.attributes= values
    end
  
  end
end