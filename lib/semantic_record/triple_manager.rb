require 'rdf/redland'
require 'curb'

module TripleManager

  @@transit_model = Redland::Model.new( Redland::MemoryStore.new )

  def self.describe(uri)
    #unless exists_as_subject?(uri)
      count = @@transit_model.size
      populate_model_with_result( "CONSTRUCT {<#{uri}> ?p ?o} WHERE {<#{uri}> ?p ?o}" )
      populate_model_with_result_from_http(uri)
    #end
  end

  def self.property_for(s,p)
    #unless exists_as_subject?( p )
      populate_model_with_result_from_http( p )
    #end 

    resource = @@transit_model.get_resource( Redland::Uri.new(p) )
    value = get_objects(s,p)
    
    return {:value => value,
            :range => resource.try(:get_property, Redland::Uri.new("http://www.w3.org/2000/01/rdf-schema#range") ),
            :domain => resource.try(:get_property, Redland::Uri.new("http://www.w3.org/2000/01/rdf-schema#domain") )
    }
  end
  
  def self.properties_for(s)
    query_string = "SELECT ?result WHERE {<#{s}> ?result ?object}"

    get_by_sparql(query_string)    
  end

  def self.populate_model_with_result_from_http(uri)
    puts "getting for #{uri}"
    curl = Curl::Easy.new(uri)
    curl.headers["Accept"] = "application/rdf+xml"
    curl.follow_location = true
    curl.connect_timeout = 2
    curl.max_redirects = 5
    begin 
      body = curl.perform
      # only process responce if content-type matches
      if !!(curl.content_type =~ /application\/rdf\+xml/)
        parser = Redland::Parser.new
        parser.parse_string_into_model(@@transit_model,curl.body_str,Redland::Uri.new( uri ))            
        puts "success"
      end
    rescue
        
    end  
  end
  
  def self.attribute(uri)
    @@transit_model.get_resource(uri)    
  end

  def self.populate_model_with_result(query)
    q = query
    parser = Redland::Parser.new
    SemanticRecord::Pool.connections.each do |connection|
      #puts "#{connection.socket.uri} with: #{q}"
      
      content = connection.socket.query(q,:result_type => RubySesame::DATA_TYPES[:RDFXML],:infer => true )
      parser.parse_string_into_model(@@transit_model,content,Redland::Uri.new( "http://example.org/" ))           
    end
  end

  def self.get_by_sparql(query_string,with_population=false)
    
    
    query = Redland::Query.new(query_string)
    result = @@transit_model.query_execute(query)
    
    #if result.size == 0
      parser = SparqlParser.new
      query_object = parser.parse(query_string)
      bindings = "#{query_object.query_part.bindings} ?p ?o"
      where_clause = query_object.query_part.where.group_graph_pattern.text_value.insert(1,"#{bindings}.")

      construct_query = "CONSTRUCT {#{bindings}} WHERE #{where_clause} "

      populate_model_with_result(construct_query)
    #end
    query = Redland::Query.new(query_string)
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

  def self.get_subjects(s, options = {} )
    conditions = options.delete(:conditions)
    query_string = "SELECT DISTINCT ?result WHERE {?result <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> #{s}. #{conditions} }" 
#    raise  query_string.inspect
    get_by_sparql(query_string,false)     
  end

  def self.get_objects(subject,predicate,*args)

    unless args.empty?
      filter = "FILTER ( lang(?result) = '#{args[0][:lang]}' )"
    else
      filter  = nil
    end
  
    query_string = "SELECT ?result WHERE {<#{subject}> <#{predicate}> ?result #{filter} }"
    
    #puts query_string
    
    get_by_sparql(query_string)
  end

  def self.add(subject,predicate,object,context=nil)
    s,p,o = build(subject,predicate,object)
    @@transit_model.add(s,p,o,context)
  end

  def self.update(subject,attributes)
    attributes.each do |predicate,objects|
      sub,pre = build(subject,predicate,nil)
      @@transit_model.find(sub,pre).each do |removable_statement|
        @@transit_model.delete_statement(removable_statement)
      end   
      objects.each do |object|
        s,p,o = build(subject,predicate,object)
        @@transit_model.add(s,p,o) 
      end
    end
  end
  
  def self.count
    @@transit_model.size
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