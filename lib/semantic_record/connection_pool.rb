require 'yaml'
module SemanticRecord::Pool
  
  
  @connections = []
  
  def self.register(connection)
    @connections << Connection.new(connection)
  end
  
  def self.get_default_store
    connections.select{|con| con.default && con.writable}.first
  end
  
  def self.connections
    @connections
  end
  
  def self.load(file = nil)
    if file
      process_config(file)
    else
      raise ArgumentError, "no rails environment found, propably not running in an rails setting?"
    end
  end
  
  private 
  
  def self.process_config(file)
    refs = open(file) {|f| YAML.load(f) }
    
    refs.each do |uri,attributes|
      register( {:uri => uri, :type => attributes["type"],:default => attributes["default"], :writable => attributes["writable"], :repository => attributes["repository"] } )
    end
  end
  
  class Connection
    attr_reader :uri, :writable, :default, :type, :socket, :repository
    
    def initialize(connection)
      @socket = init(connection)
    end
    
    private 
    
    def init(connection)
      @uri = connection[:uri]
      @type = connection[:type]
      @writable = connection[:writable]
      @default = connection[:default]
      
      RubySesame::Server.new(@uri).repository( connection[:repository] )
    end
    
  end
  
end