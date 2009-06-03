module SemanticRecord
  require "rexml/document"
  
  TRANSACTION_STATEMENT = "transaction"
  REMOVE_STATEMENT = "remove"
  ADD_STATEMENT = "add"
  URI_STATEMENT = "uri"
  LITERAL_STATEMENT = "literal"
  NULL = "null"
  # Builds a transaction document for updates in the store
  class TransactionFactory < REXML::Document
    #Creates a new XML-file and adds a transaction statement
    def initialize
      super
      add_transaction_statement
    end

    # Add a Node calles transaction to the document
    def add_transaction_statement
      self.add( build_element( TRANSACTION_STATEMENT ) )
    end

    # adds an remove-statement to the transaction document
    # * s -> the subject to be removed
    # * p -> the predicate to be removed
    # * o -> the object to be removed
    def add_remove_statement(s, p, o)
      remove = build_element( REMOVE_STATEMENT )
      #--
      # TODO move adding of multiple elements to support/helper
      #++
      build_triple(s,p,o).each do |resource|
        remove.add(resource)
      end

      self.root.add(remove)
    end

    # adds an add-statement to the transaction document
    # * s -> the subject to be added
    # * p -> the predicate to be added
    # * o -> the object to be added
    def add_add_statement(s, p, o)
      add_state = build_element( ADD_STATEMENT )
      #--
      # TODO move adding of multiple elements to support/helper
      #++
      build_triple(s,p,o).each do |resource|
        add_state.add(resource)
      end

      self.root.add(add_state)
    end
    
    # if theirs an update the old triple has to be deleted and the new values added to the store
    def add_update_statement(s, p, o, new_object)
      #--
      # TODO modify for applying changes that effect more than the object
      #++
      o.each do |_o| 
        add_remove_statement(s,p,_o)  
      end
      new_object.each do |_new|
       add_add_statement(s,p,_new)
      end
      
      #raise self.to_s.inspect
    end
    
    protected
    
    # creates a triple that could be added to the transaction document
    def build_triple(s, p, o)
      returning [] do |triple|
        #raise s.inspect
        
        # ugly!!! first should not called directly
        [s.first,p,o].each do |resource|
          #--
          # FIXME if handling of properties ever changes (resource.type == URI)
          #++
          
          
          if resource =~ /http:\/\//
            triple << build_uri_element(resource)
          elsif resource.nil?
            triple << build_element( NULL )
          else
            triple << build_literal_element(resource)
          end
        end
      end
    end    
    
    # If the value of a object is *uri* then build a uri-node
    def build_uri_element(value)
      #--
      # TODO make me pretty
      #++
      b = build_element( URI_STATEMENT )
      b.text=(value)
      return b
    end
    
    # If the value of an object ist a *literal* build a literal-node
    def build_literal_element(value)
      #--
      # TODO make me pretty
      #++
      b = build_element( LITERAL_STATEMENT )
      b.text=(value)
      return b
    end
    #Creates a new Node with the specific name
    def build_element(name)
      return REXML::Element.new(name)
    end
  end
end

