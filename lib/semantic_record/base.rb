require 'rubygems'
require 'ruby-sesame'
require 'json'

module SemanticRecord

  class Base
      attr_reader :uri

      class << self  
        attr_accessor :base, :connection,:rdf_type,:uri
      end

      def ==(comparable)
          self.uri == comparable.uri
        end
      
      def initialize(uri)
        @uri = uri
        @presaved_attributes = {}
        
        TripleManager.describe(uri)
          
        if self.new_record?                 
         self.rdf_type = self.class
        end
      end

      def new_record?
        exists = TripleManager.exists_as_subject?(self.uri)
      
        !exists
      end

      def type
        proxy_getter(:rdf_type)
      end
      
      def attribute(p_uri)
        TripleManager.property_for(uri,p_uri)
      end
      
      def attributes
        TripleManager.properties_for(uri)
      end
      
      def destroy!
         remove = 
         "<transaction>
          <remove>
            <uri>#{uri}</uri>
            <null/>
            <null/>
          </remove>
          </transaction>"      
        connection.add!(remove, "application/x-rdftransaction")
      end
            
      def save
        if new_record?
          puts "saving new"
          begin 
            @presaved_attributes.each {|predicate,value|
              value.each do |val|
                   TripleManager.add(uri,predicate,val)
              end

              @presaved_attributes.delete(predicate)
            }
          rescue
            return false
          end           
        else
          puts "saving old"
          begin

            TripleManager.update(uri,@presaved_attributes)
            @presaved_attributes = {}
          rescue ArgumentError
            puts $!
            return false
          end
        end
        true
      end
      
      def self.method_missing(mth,*args)
        if mth.to_s =~ /^find_by_([_a-zA-Z]\w*)$/
          pp = $1
        
          if self == SemanticRecord::Base
              s = "?nil"
            else
              uri = URI.parse self.uri #"#{self.base}#{self}"
              if uri.absolute && uri.path
                s = "<#{uri.to_s}>"
              else
                raise ArgumentError, "base uri seems to be invalid"
              end
          end
          
          a = args.first.class == Array ? args.first : args
          
          
          objects = a.collect{|arg| "<#{arg}>"}.join(",")
           
          conditions = "?result <#{pp.expand}> #{objects}."
          
          instances_response = TripleManager.get_subjects(s, :conditions => conditions)
        else
          super
        end
        
      end
      
      def method_missing(mth,*args)
        if mth.id2name.end_with?("=")
          proxy_setter(mth,*args)
        else
          proxy_getter(mth,*args)
        end
      end

      def self.inherited(receiver)
        receiver.base = self.base
        receiver.rdf_type = "http://http://www.w3.org/2000/01/rdf-schema#Class"
      end

      def self.count
        TripleManager.count
      end
      
      def self.rdf_type
        @rdf_type ||= "http://www.w3.org/2002/07/owl#Thing"
      end
      
      def self.uri
        @uri ||= "#{self.base}#{self}"
      end
            
      def self.base
        @base ||= "http://example.org/"
      end
      
      def self.find_by_uri
        
      end
      
      def self.find_by_sparql(query)
        TripleManager.get_by_sparql(query,true)
      end
    
      
      def self.find
        # if self isn't an inherited form of this
        # class then return all existing instances
        
       if self == SemanticRecord
          s = "?nil"
        else
          uri = URI.parse self.uri #"#{self.base}#{self}"
          if uri.absolute && uri.path
            s = "<#{uri.to_s}>"
          else
            raise ArgumentError, "base uri seems to be invalid"
          end
        end
                
        instances_response = TripleManager.get_subjects(s)

      end
      
      def find_others
        self.class.find_by_rdf_type(self.uri)
      end
      
      def name(fallback = :rdfs_label)
        name = self.send(fallback)
        
        name.blank? ? uri.humanize : name
      end
      
      def title()
        name(:aktors_has_title_)
      end
      
      protected
      
      def self.check_context
   
      end
      
      def proxy_setter(mth,*args)
        predicate = mth.id2name.expand#(mth)
        
        @presaved_attributes[predicate] = args.flatten
      end  

      def proxy_getter(mth,*args)
           
        predicate = mth.id2name.expand#(mth)
        
        if @presaved_attributes.has_key?(predicate)
           value_response = @presaved_attributes[predicate]
        else
           value_response = TripleManager.get_objects(uri,predicate,*args)  
        end
        
      end
    
    def expand(name)
        ns, predicate = name.id2name.split("_",2)
        if predicate.blank? 
          raise Namespaces::NoPredicateError, "no valid predicate defined"
        end
        namespace = Namespaces.resolve(ns)

        predicate = predicate.chomp("=")
        
        return namespace + predicate
      end
    end
    
    
end