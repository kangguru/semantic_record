module SemanticRecord
  class Base
    include SesameAdapter
    #Defines the location of the Sesame Store. the repository and a base_uri
    def self.inherited(someClass)
      someClass.extend(Base::ClassMethods)
      someClass.send(:include,Base::InstanceMethods)

      someClass.location="http://localhost:8080/openrdf-sesame"  
      someClass.repository="study-stash"
      someClass.base_uri="http://example.org/music#"
      someClass.rdf_type = someClass.name#.split("::").last.to_s
      someClass.attributes = {}

      someClass.construct
    end
  end

  module Base::InstanceMethods
    attr_accessor_with_versioning :uri

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
      end

      SemanticRecord::Base.update(transaction_doc)
    end

    def add!(p,o)
      transaction_doc = SemanticRecord::TransactionFactory.new
      transaction_doc.add_add_statement(uri,p,o)
      
      SemanticRecord::Base.update(transaction_doc)
      self.class.construct
      self.send(p.to_human_name + "=",o)
    end

    def remove!(p,o=nil)
      transaction_doc = SemanticRecord::TransactionFactory.new
      transaction_doc.add_remove_statement(uri,p,o)
      
      SemanticRecord::Base.update(transaction_doc)
      self.class.construct      
    end

    # Sets all the Values for a Object
    def attributes=(values)
      values.each do |key,value|
        self.send(key.to_s + "=",SemanticRecord::Property.new( value['value'],value['type'] ))
      end      
    end

    # Creates a new Object with the attributes and their values in the values-Hash
    def initialize(values={})      
      self.attributes= values
    end
  end

  module Base::ClassMethods
    ###
    ### attribute accessors that are independet from superclass
    ###

    attr_accessor :rdf_type, :attributes, :base_uri, :attributes_names
    # Gets all the property names and their types from the Store and puts them in the attributes hash
    def construct
      construct_attributes
      construct_methods
    end
    
    def construct_attributes
      # TODO was ist wenn Namen kollidieren
      self.attributes = ResultParserJson.hash_values(self.find_by_sparql("SELECT DISTINCT ?property_name ?property_type WHERE { { ?property_name rdfs:domain <#{uri}>  } UNION {?s rdf:type <#{uri}>; ?property_name ?o. } OPTIONAL { ?property_name rdfs:range ?property_type.}  }"))
    end

    #Gets all instances with their attributes
    def construct_methods
      attr_accessor_with_versioning *(attributes_names) unless attributes_names.empty?        

      attributes.each do |key,value|
        class_eval %{
          def self.find_by_#{key.to_human_name} (val)
            instances_result = ResultParserJson.parse(self.find_by_sparql(\"SELECT ?uri #{attributes_names.to_sparql_properties} WHERE {?uri <#{key}> '\#{val}' #{attributes.to_optional_clause} } \"))
            build(instances_result)
          end
        }
      end
    end 

    def uri
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
    def find(uri_or_scope)
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

    #Creates new Objects from the desired class
    def build(instances_result)
      returning [] do |instances|        
        instances_result.each {|k|
          instances << new(k)
        }        
      end        
    end

    # Generates an array with all attribute-names without their namespace
    def attributes_names
      attributes.keys.collect {|key|
        key.to_human_name
      }
    end

    ###
    ### class initializer calls
    ###

  end
end