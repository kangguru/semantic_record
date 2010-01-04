module SemanticRecord
  module Support
    Symbol.class_eval do
      def expand
        ns, predicate = self.id2name.split("_")
        if predicate.blank? 
          raise Namespaces::NoPredicateError, "no valid predicate defined"
        end
        namespace = Namespaces.resolve(ns)

        predicate = predicate.chomp("=")
        
        return namespace + predicate
      end
    end
  end
end