module SemanticRecord
  #A semantic property that has a value and a type
  class Property 
    attr_accessor :type, :value
    
    #Creates a new Property-Instance with a value and a type(Uri or literal), the default ist literal
    def initialize(value,type = "literal")
      @type = type
      @value = value
      
    end
  end  
end