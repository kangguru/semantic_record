module SemanticRecord
  # Extents Ruby-classes with some usefull methods
  module Support
    Array.class_eval do
      
      # Extents *Array* with a method that takes every Array-element and adds a *?* -> for Sparql
      def to_sparql_properties
        self.size > 0 ? "?#{self.join(' ?')}" : ""
      end
    
      # Extents *Array* with a method that reduces a array to his first element
      def first!
        a = self.first
        self.clear << a
      end
      
      # Extents *Array* with a method that reduces a array to his last element
      def last!
        a = self.last
        self.clear << a
      end
    end
    
    Hash.class_eval do
      
      # Extents *Hash* with a method that creates OPTIONAL-clauses for every element of the Hash -> for Sparql
      def to_optional_clause
        properties = collect {|k,v| "OPTIONAL { ?uri <#{k}> ?#{k.to_human_name}. }" }.join(' ')
      end      
    end    
    
    String.class_eval do
      # TODO give me a sleeker name 
      # Extents *String* with a method that strips out the namespace of a string
      def to_human_name
        self.split('#').size > 1 ? self.split('#').last : self.split('/').last
      end
    end
  end  
end