require 'rubygems'
require 'ruby-sesame'
require 'json'

module SemanticRecord
  class Base
    attr_reader :uri#, :connection  

    cattr_accessor :namespace

    class << self  
      attr_accessor :base, :connection
    end


    # this should be somewhere external
    self.namespace = {:rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
      :rdfs => "http://www.w3.org/2000/01/rdf-schema#", 
      :owl => "http://www.w3.org/2002/07/owl#",
      :xsd => "http://www.w3.org/2001/XMLSchema#",
      :base => self.base}


      def initialize(uri)
        @uri = uri
        @presaved_attributes = {}
        
        #connection = self.class.connection
          
       if self.new_record?        
        self.rdf_type= self.class
       end
      end

      def new_record?
        new_record = self.class.parse( connection.query( "SELECT ?result WHERE {<#{self.uri}> ?property ?result} LIMIT 1" ) )

        new_record.empty? ? true : false
      end

      def type
        proxy_getter(:rdf_type)
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
          begin 
            @presaved_attributes.each {|predicate,value|
              v = value.collect {|val|
                if val.kind_of?(SemanticRecord) || (val.kind_of?(Class) && val.respond_to?(:uri) )
                "<#{val.uri}>"
                else
                "\"#{val.to_s}\""
                end
              }.join(",")
              
              connection.add!("<#{self.uri}> <#{predicate}> #{v}  .")            
              
              @presaved_attributes.delete(predicate)
            }
          rescue
            return false
          end           
        else
          begin
           t = Foxen::TransactionFactory.new
            @presaved_attributes.each {|predicate,value|
              t.add_remove_statement(self.uri,predicate,nil)
              
              value.each do |val|
                if val.kind_of?(SemanticRecord) || (val.kind_of?(Class) && val.respond_to?(:uri) )
                  t.add_add_statement(self.uri,predicate,val.uri)
                else
                 t.add_add_statement(self.uri,predicate,val.to_s)
                end
              end
              
              

              @presaved_attributes.delete(predicate)
            }
            
            connection.add!(t.to_s, "application/x-rdftransaction")
          rescue
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
        receiver.connection = self.connection
      end

      def self.rdf_type
        self
      end
      
      def self.uri
        "#{self.base}#{self}"
      end
      
      def self.find_by_uri
        
      end
      
      def self.find
        #
        # if self isn't an inherited form of this
        # class then return all existing instances
        #
        if self == SemanticRecord
          selector = "?nil"
        else
          uri = URI.parse "#{self.base}#{self}"
          if uri.absolute && uri.path
            selector = "<#{uri.to_s}>"
          else
            raise ArgumentError, "base uri seems to be invalid"
          end
        end

        instances_response = parse( connection.query("SELECT ?result WHERE {?result <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> #{selector}}") )

      end
      
      
      ##
      # TODO: make me non public and more comfortable
      ##
      def self.establish_connection(uri,respository)
        @connection = RubySesame::Server.new(uri).repository(respository)
      end

      protected
      
      #attr_accessor :connection
      
      def connection
        self.class.connection
      end
      
      def proxy_setter(mth,*args)

        predicate = mth.to_sym.expand#(mth)
        
        @presaved_attributes[predicate] = args.flatten
      end  

      def proxy_getter(mth,*args)

        predicate = mth.to_sym.expand#(mth)

        if @presaved_attributes.has_key?(predicate)
          value_response = @presaved_attributes[predicate]
        else
          q = "SELECT ?result WHERE {<#{self.uri}> <#{predicate}> ?result}"
          value_response = self.class.parse( connection.query(q) )
        end
       
        if value_response.size <= 1
          value_response.empty? ? nil : value_response.first
        else
          return value_response
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
      
      def self.parse(response)
        #puts response
        json = JSON.parse( response )
        returning [] do |instances|
          json['results']['bindings'].each do |binding|
            if binding['result']['type']=="uri"
              instances << new(binding['result']['value'])
            else
              instances << binding['result']['value']
            end
          end
        end  
      end
    end
end