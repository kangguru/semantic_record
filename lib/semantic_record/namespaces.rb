module Namespaces
  
  @namespace = {:rdf => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
    :rdfs => "http://www.w3.org/2000/01/rdf-schema#", 
    :owl => "http://www.w3.org/2002/07/owl#",
    :xsd => "http://www.w3.org/2001/XMLSchema#"}

  ##
  #  expand namespace to full uri
  #  key can be either symbol oder string
  ## 
  def self.resolve(name)
    @namespace[name.to_sym].blank? ? (raise NoNamespaceError,"no matching namespace found") : @namespace[name.to_sym]
  end  
  
  ##
  #  register new namespaces, can process multiple namespaces at once
  #  format is {:key => "value"}
  ##
  def self.register(pair)
    pair.each do |key,value|
      @namespace[key.to_sym] = value
    end
  end

  class NoNamespaceError < StandardError
  end
  
  class NoPredicateError < StandardError
    
  end
end
