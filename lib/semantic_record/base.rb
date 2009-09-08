module SemanticRecord
  
  class Base
#    include SesameAdapter
    #Defines the location of the Sesame Store. the repository and a base_uri
    extend(SemanticRecord::SesameAdapter)
    
    def self.inherited(someClass)
      someClass.extend(Base::ClassMethods)
      someClass.send(:include,Base::InstanceMethods)
      someClass.base_uri = "http://knowledge.erco.com/products#"
      someClass.rdf_type = someClass.name#.split("::").last.to_s
      someClass.attributes = {}
      someClass.construct
    end
    
    def self.construct_classes
      classes = ResultParserJson.hash_values(self.find_by_sparql("SELECT ?property_name ?property_type WHERE { ?property_name rdfs:subClassOf <http://knowledge.erco.com/products#Leuchte>. FILTER (!isBlank(?property_name)) }"))
      
      g = []
      classes.keys.each do |key|
        g << klass_name = key.to_human_name.gsub('-','_').camelize
      end
      
      #raise g.inspect
#      raise g.inspect
      classes.keys.each do |key|
    #    raise key.inspect
        klass_name = key.to_human_name.gsub('-','_').camelize
#        raise klass_name.inspect
        Object.class_eval %{
          class #{klass_name} < SemanticRecord::Base
            self.base_uri = "#{key.extract_base}#"
            self.rdf_type = "#{key.to_human_name}"
          end
        }
      end
    
      #e = Emanon.new
    
    end

    
    
  end

  module Base::InstanceMethods
    @attributes = []
   # attr_accessor_with_versioning :uri

    #--
    #FIXME perform a real update! implement instaniation of new resource
    #++
    # Saves all attributes to the Sesame Triple Store
    def save
      transaction_doc = SemanticRecord::TransactionFactory.new
      self.class.attributes.keys.each do |key|
        unless attributes[key.to_human_name].blank?
          value_new = attributes[key.to_human_name]['value']#self.send(key.to_human_name)
          value = attributes[key.to_human_name]['history'].last#self.send(key.to_human_name,:old)
        # TODO: 
#        raise value.inspect unless value.blank?
          transaction_doc.add_update_statement(uri,key,value,value_new) unless value.blank?
        end
      end      
      self.class.update(transaction_doc)
    end
      
    #Adds the given p(roperty) and o(object) to the actucal instance/subject  
    def add!(p,o)
      transaction_doc = SemanticRecord::TransactionFactory.new

      transaction_doc.add_add_statement(uri,p,o)
#      raise transaction_doc.to_s.inspect      
      self.class.update(transaction_doc)
      # make the schema changes available
      self.class.construct
      
      self.send(p.to_human_name + "=",o)
#      raise self.attributes.inspect
      
      # update the instance
      
    end
    
    # remove the given triple from the store, o can be set to a specific value
    def remove!(p,o=nil)
      # TODO perhaps this should be moved to the property class -> jazz.composer.destory!
      transaction_doc = SemanticRecord::TransactionFactory.new
      transaction_doc.add_remove_statement(uri,p,o)
#      raise transaction_doc.to_s.inspect
      self.class.update(transaction_doc)
      self.class.construct      
    end

    # Sets all the Values for a Object
    def attributes=(values)
      @attributes = values
#       values.each do |key,value|
#         @attributes << {key => {"value" => value['value'],"type" => value['type'] } }
# #        self.send(key.to_s + "=",SemanticRecord::Property.new( value['value'],value['type'] ))
#       end      
    end
    
    def attributes
      @attributes
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

    attr_accessor :rdf_type, :attributes, :attributes_names
    attr_reader :base_uri
        
    def base_uri=(value)
      @base_uri = value
      construct
    end
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
      #attr_accessor_with_versioning *(attributes_names) unless attributes_names.empty?        
      [:uri,attributes_names].flatten.each do |attribute|
        class_eval %{
          def #{attribute}
               attributes['#{attribute}']['value']
          end
           
           def set_#{attribute} (value, init = false)
             
             if attributes['#{attribute}'].nil?
               attributes['#{attribute}'] = {'history' => []}
             end

             old = attributes['#{attribute}']['value']

             
             if value.class.to_s == "String"
                  attributes['#{attribute}']['value']=[value]
                  attributes['#{attribute}']['type']='literal'
             elsif value.class.to_s == "URI:HTTP"
                  attributes['#{attribute}']['value']=value.to_s
                  attributes['#{attribute}']['type']='uri'
                #raise "uri: " +  attributes[#{attribute}].inspect
             else
               raise ArgumentError
             end
              attributes['#{attribute}']['history'].unshift old
           end
           
           def #{attribute}= (value)
             set_#{attribute} value
           end
        }
      end

      attributes.each do |key,value|
        class_eval %{
          def self.find_by_#{key.to_human_name} (val)
            instances_result = ResultParserJson.parse(self.find_by_sparql(\"SELECT ?uri #{attributes_names.to_sparql_properties} WHERE {?uri <#{key}> '\#{val}' #{attributes.to_optional_clause} } \"))
           instances_result.nil? ? [] : build(instances_result)
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
        if instances_result.blank?
          raise ArgumentError, "#{uri_to_search} not found!"
        end
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