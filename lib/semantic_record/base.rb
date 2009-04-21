#require "ruby-sesame"

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
      
      subClass.base_uri="http://example.org/music#"
      subClass.rdf_type = subClass.name#.split("::").last.to_s
      subClass.attributes = {}

      def subClass.construct_attributes
        # TODO was ist wenn Namen kollidieren
        self.attributes, self.attributes_names = ResultParserJson.hash_values(self.query("SELECT DISTINCT ?property_name ?property_type WHERE { { ?property_name rdfs:domain <#{uri}>  } UNION {?s rdf:type <#{uri}>; ?property_name ?o. } OPTIONAL { ?property_name rdfs:range ?property_type.}  }"))
      end
      
      def subClass.construct_methods
        attr_accessor *(attributes_names) unless attributes_names.empty?        
        
        attributes.each do |key,value|
          self.class_eval("def self.find_by_#{key.to_human_name} (val)
           instances_result = ResultParserJson.parse(self.query(\"SELECT ?uri WHERE {?uri <#{key}> '\#{val}' } \"))
           build(instances_result) end
          ") 
        end
      end 

      def subClass.uri
        # TODO change my name
        "#{base_uri}#{rdf_type}"
      end
            
      def subClass.find(uri_or_scope)
        if uri_or_scope.kind_of?(Symbol)          
          instances_result = ResultParserJson.parse(self.query("SELECT ?uri #{attributes_names.to_sparql_properties} WHERE { ?uri rdf:type <#{uri}> #{attributes.to_optional_clause} }") )
          case uri_or_scope
           when :all
             instances_result = instances_result
           when :first
             instances_result.first!
           when :last
             instances_result.last!
           else raise ArgumentError, "bla"
          end
        elsif uri_or_scope.kind_of?(String)
          # TODO 
          uri_to_search = URI.parse(uri_or_scope)
          instances_result = ResultParserJson.parse(self.query("SELECT ?uri #{attributes_names.to_sparql_properties} WHERE { ?uri rdf:type <#{uri}> #{attributes.to_optional_clause} FILTER (?uri = <#{uri_to_search.to_s}>) }") )
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
    
    def attributes=(values)
      values.each do |key,value|
        self.send(key.to_s + "=",value)
      end      
    end
    
    def initialize(values={})      
      self.attributes= values
    end
  
  end
end