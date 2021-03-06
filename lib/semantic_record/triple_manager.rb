require 'rdf/redland'
require 'httparty'
require 'httparty_sober'

# require 'moneta'
# require 'moneta/memcache'
# 
# APICache.store = Moneta::Memcache.new(:server => "localhost")

module TripleManager
  
  class RemoteRessource
    include HTTParty
    include HTTParty::Sober

    headers 'Accept' => "application/rdf+xml"
  end
  
  @@cache_timeout = Time.now
  @@transit_model = Redland::Model.new( Redland::MemoryStore.new )
  
  def self.cache_timeout=(seconds)
    @@cache_timeout = seconds
  end
  
  def self.describe(uri)
    #unless exists_as_subject?(uri)
      count = @@transit_model.size
      populate_model_with_result( "CONSTRUCT {<#{uri}> ?p ?o} WHERE {<#{uri}> ?p ?o}" )
      #populate_model_with_result_from_http(uri)
    #end
  end

  def self.property_for(s,p)
    puts "#{s}, #{p}"
    if @@transit_model.find(s,p).empty?
      populate_model_with_result_from_http( s )
      unless exists_as_subject?( p )
        populate_model_with_result_from_http( p )
      end 
    end

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

  
  # 
  #   response = Query.get_with_caching("http://google.com")
  # 
  #   @@transit_model = Redland::Model.new( Redland::MemoryStore.new )
  # 
  #   puts response.headers["content-type"]
  # 
  #   parser = Redland::Parser.new
  #   parser.parse_string_into_model(@@transit_model,response,Redland::Uri.new( "http://example.org" ))            
  #   puts "success"
  # 
  #   

  def self.populate_model_with_result_from_http(uri)
    puts "getting for #{uri}"
    # curl = Curl::Easy.new(uri)
    # curl.headers["Accept"] = "application/rdf+xml"
    # curl.follow_location = true
    # curl.connect_timeout = 2
    # curl.max_redirects = 5
    begin 
      response = RemoteRessource.get_with_caching(uri)
      puts response.headers['content-type']
      # only process responce if content-type matches
      if !!(response.headers['content-type'].to_s =~ /application\/rdf\+xml/)
        parser = Redland::Parser.new
        parser.parse_string_into_model(@@transit_model,response.to_s,Redland::Uri.new( uri ))            
        puts "success"
      else 
        puts "fail :/"
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
    
    #query = Redland::Query.new(query_string)
    #result = @@transit_model.query_execute(query)
    
    #if result.size == 0
    if Time.now - @@cache_timeout > 60
      puts "=========================="
      puts "clear"
      puts "=========================="
      Redland::Model.new( Redland::MemoryStore.new )
      @@cache_timeout = Time.now
    end
    
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
    #puts predicate
    #puts @@transit_model.find(subject,predicate).size

    #populate_model_with_result_from_http( subject )    
    
    unless args.empty?
      filter = "FILTER ( lang(?result) = '#{args[0][:lang]}' )"
    else
      filter  = nil
    end
  
    query_string = "SELECT ?result WHERE {<#{subject}> <#{predicate}> ?result #{filter} }"
    
    result = get_by_sparql(query_string)
    
    #puts query_string
    if result.empty?
      populate_model_with_result_from_http( subject )      
      get_by_sparql(query_string)
    else
      result
    end
  end

  def self.add(subject,predicate,object,context=nil)
    trans = Foxen::TransactionFactory.new
    trans.add_add_statement(subject,predicate,object)
    s,p,o = build(subject,predicate,object)
    @@transit_model.add(s,p,o,context)
    SemanticRecord::Pool.get_default_store.socket.add!(trans.to_s, "application/x-rdftransaction")
  end

  def self.update(subject,attributes)
    trans = Foxen::TransactionFactory.new
    
    attributes.each do |predicate,objects|
      sub,pre = build(subject,predicate,nil)
      trans.add_remove_statement(subject,predicate,nil)
      @@transit_model.find(sub,pre).each do |removable_statement|
        @@transit_model.delete_statement(removable_statement)
      end   
      objects.each do |object|
        trans.add_add_statement(subject,predicate,object)
        s,p,o = build(subject,predicate,object)
        @@transit_model.add(s,p,o) 
      end
    end
    #raise trans.to_s.inspect
    SemanticRecord::Pool.get_default_store.socket.add!(trans.to_s, "application/x-rdftransaction")
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

    if object.kind_of?(SemanticRecord) || (object.kind_of?(Class) && object.respond_to?(:uri) || object.to_s =~ /https?:\/\//)
      puts "write a ressource #{object.inspect}"
      o = Redland::Resource.new( object.respond_to?(:uri) ? object.uri : object.to_s )
    else
      puts "write a literal #{object.inspect}"
      o = object.to_s
    end

    return s,p,o      
  end
end