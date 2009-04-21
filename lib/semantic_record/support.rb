module SemanticRecord
  module Support
    Array.class_eval do
      def to_sparql_properties
        self.size > 0 ? "?#{self.join(' ?')}" : ""
      end
      
      def first!
        a = self.first
        self.clear << a
      end
      
      def last!
        a = self.last
        self.clear << a
      end
    end
    
    Hash.class_eval do
      def to_optional_clause
        properties = collect {|k,v| "OPTIONAL { ?uri <#{k}> ?#{k.to_human_name}. }" }.join(' ')
        
#        properties!="" ? "?uri #{properties}" : ""
      end      
    end    
    
    String.class_eval do
      # TODO give me a sleeker name 
      def to_human_name
        self.split('#').size > 1 ? self.split('#').last : self.split('/').last
      end
    end
  end  
end