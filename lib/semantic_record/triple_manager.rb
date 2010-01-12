require 'rdf/redland'

module TripleManager
  
    @@transit_model = Redland::Model.new( Redland::MemoryStore.new )
    
   def self.describe(uri)
     # span a thread to retrive http-data
     unless exists_as_subject?(uri)

       populate_model_with_result( "CONSTRUCT {<#{uri}> ?p ?o} WHERE {<#{uri}> ?p ?o}" )
     end
   end
   
   
   def self.populate_model_with_result(query)
      q = query
      parser = Redland::Parser.new
      SemanticRecord::Pool.connections.each do |connection|
          content = connection.socket.query(q,:result_type => RubySesame::DATA_TYPES[:RDFXML] )
          parser.parse_string_into_model(@@transit_model,content,Redland::Uri.new( "http://example.org/" ))           
      end
   end
   
   def self.get_subjects(s)
     populate_model_with_result("CONSTRUCT {?uri ?p ?o} WHERE {?uri ?p ?o. ?uri <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> #{s}}")
     
     query = Redland::Query.new("SELECT ?result WHERE {?result <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> #{s}}" )
     result = @@transit_model.query_execute(query)
       
     returning [] do |res|
       while !result.finished?
         value = result.binding_value_by_name("result")
         if value.resource?
           res << SemanticRecord::Base.new(value.uri.to_s)
         else
           res << value.to_s
         end
         result.next
       end
     end
   end

   def self.get_objects(subject,predicate)
     #puts "query: #{subject} for #{predicate}, #{@@transit_model.size}"
     
     query = Redland::Query.new("SELECT ?result WHERE {<#{subject}> <#{predicate}> ?result}" )
     result = @@transit_model.query_execute(query)
       
     res = []
     while !result.finished?
       value = result.binding_value_by_name("result")
       if value.resource?
         res << SemanticRecord::Base.new( value.uri.to_s )
       else
         res << value.to_s
       end
       result.next
     end
     
     #raise res.inspect
     res
   end

   def self.add(subject,predicate,object,context=nil)
     # s = Redland::Statement.new
     #   s.subject = Redland::Node.new(Redland::Uri.new( subject ))
     #   s.predicate = Redland::Node.new(Redland::Uri.new( predicate ))
     #   
     #   if object.kind_of?(SemanticRecord) || (object.kind_of?(Class) && object.respond_to?(:uri) )
     #     s.object = Redland::Node.new(Redland::Uri.new( object.uri ))
     #   else
     #     s.object = Redland::Node.new( object.to_s )
     #   end
     
     s,p,o = build(subject,predicate,object)
     
     #s.object = Redland::Node.new( object )
     
     @@transit_model.add(s,p,o,context)
   end
   
   def self.update(subject,attributes)
     attributes.each do |predicate,objects|
       objects.each do |object|
          s,p,o = build(subject,predicate,object)
          @@transit_model.find(s,p).each do |removable_statement|
            @@transit_model.delete_statement(removable_statement)
          end
        
          @@transit_model.add(s,p,o) 
       end
          
     end

   end


   def self.exists_as_subject?(uri)
     query = Redland::Query.new("SELECT ?result WHERE {<#{uri}> ?property ?result} LIMIT 1")
     result = @@transit_model.query_execute(query).size
     result > 0 ? true : false
   end  
   
  
    protected
    
    def self.build(subject,predicate,object)
      s = Redland::Resource.new( subject )
      p = Redland::Resource.new( predicate )
      
      if object.kind_of?(SemanticRecord) || (object.kind_of?(Class) && object.respond_to?(:uri) )
         o = Redland::Resource.new( object.uri )
      else
         o = object.to_s
      end
      
      return s,p,o      
    end
end