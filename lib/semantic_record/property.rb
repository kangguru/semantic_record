module SemanticRecord
  class Property
    attr_accessor :type, :value
    def self.bla
      
      "haha"
    end
    
    def initialize(value,type = "literal")
      @type = type
      @value = value
      
    end
  end  
end