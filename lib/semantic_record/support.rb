module SemanticRecord
  module Support
    Symbol.class_eval do
      def expand
        ns, predicate = self.id2name.split("_",2)
        if predicate.blank? 
          raise Namespaces::NoPredicateError, "no valid predicate defined"
        end
        namespace = Namespaces.resolve(ns)

        predicate = predicate.chomp("=")
        
        return namespace + predicate
      end
    end
    
    String.class_eval do
      def expand
        ns, predicate = self.split("_",2)
        if predicate.blank? 
          raise Namespaces::NoPredicateError, "no valid predicate defined"
        end
        namespace = Namespaces.resolve(ns)
        
        predicate = predicate.chomp("=")
 
        predicate = predicate.chomp("_").gsub("_","-") if predicate.end_with?("_")
        
        return namespace + predicate
      end
    end
    
    Array.class_eval do
      def uniq_by(&blk)
        transforms = []
        self.select do |el|
          should_keep = !transforms.include?(t=blk[el])
          transforms << t
          should_keep
        end
      end
    end
    
  end
end