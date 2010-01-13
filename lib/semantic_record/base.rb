require 'rubygems'
require 'ruby-sesame'
require 'json'

module SemanticRecord

  class Base
    
    
      attr_reader :uri#, :connection  

      class << self  
        attr_accessor :base, :connection,:rdf_type,:uri
      end



      def initialize(uri)
        @uri = uri
        @presaved_attributes = {}
        
        TripleManager.describe(uri)
          
        if self.new_record?                 
         self.rdf_type = self.class#= "#{Namespaces.resolve(:base)}#{self.class}"
        end
      end

      def new_record?
        exists = TripleManager.exists_as_subject?(self.uri)#self.class.parse( connection.query( "SELECT ?result WHERE {<#{self.uri}> ?property ?result} LIMIT 1" ) )
      
        !exists
      end

      def type
        proxy_getter(:rdf_type)
      end
      
      
      # FIXME refactor me
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
          begin
            TripleManager.update(uri,@presaved_attributes)
          rescue ArgumentError
            puts $!
            return false
          end
        end
        
        true
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
        #receiver.connection = self.connection
        receiver.rdf_type = "http://http://www.w3.org/2000/01/rdf-schema#Class"
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
      
      def self.find
        #
        # if self isn't an inherited form of this
        # class then return all existing instances
        #
        
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
    

      protected
      
      
      def proxy_setter(mth,*args)
        predicate = mth.to_sym.expand#(mth)
        @presaved_attributes[predicate] = args.flatten
      end  

      def proxy_getter(mth,*args)
           
        predicate = mth.to_sym.expand#(mth)

        if @presaved_attributes.has_key?(predicate)
           value_response = @presaved_attributes[predicate]
        else
           value_response = TripleManager.get_objects(uri,predicate)  
        end
        
      end
      
      # ##
      # # TODO: make me external
      # ##
      def expand(name)
        ns, predicate = name.id2name.split("_")
        if predicate.blank? 
          raise Namespaces::NoPredicateError, "no valid predicate defined"
        end
        namespace = Namespaces.resolve(ns)

        predicate = predicate.chomp("=")
        
        return namespace + predicate
      end
    end
end