module SemanticRecord::Pool
  
  @connections = []
  
  def self.register(connection)
    @connections << Connection.new(connection)
  end
  
  def self.connections
    @connections
  end
  
  
  class Connection
    attr_reader :uri, :writable, :default, :type, :socket, :repository
    
    def initialize(connection)
      @uri = connection[:uri]
      @type = connection[:type]
      @writable = connection[:writable]
      @default = connection[:default]
      @socket = RubySesame::Server.new(@uri).repository( connection[:repository] )
    end
    
  end
  
end