module SemanticRecord
  # Extents Ruby-classes with some usefull methods
  module Support
    Module.class_eval do
      # replacement for the standard attr_accessor. extends it to behave like an versioning system, to keep track of old values after changes
      def attr_accessor_with_versioning(*attributes)
        # inspired from: http://www.archivum.info/comp.lang.ruby/2008-04/msg03767.html
        attributes.each { |attribute|
          module_eval %{
            def #{attribute} (version = :actual)
              if version == :actual
                @#{attribute}
              elsif version == :old
                @#{attribute}_old
              else
                raise ArgumentError, "unkown access symbol"
              end
            end

            def set_#{attribute} (value, init = false)
              if init
                @#{attribute}_modified = nil
                @#{attribute}_old = nil
              end
              if @#{attribute}_modified == nil
                @#{attribute}_modified = 0
              elsif @#{attribute}_modified == 1
                @#{attribute}_old = @#{attribute}
              end
              @#{attribute} = value
              @#{attribute}_modified += 1
            end

            def #{attribute}= (value)
              set_#{attribute} value
            end
          }
        }
      end
    end
    
    Array.class_eval do
      
      # Extents *Array* with a method that takes every Array-element and adds a *?* at the beginning of every element  -> for Sparql
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
      
      def extract_base
        self.split('#').first
      end
    end
  end  
end