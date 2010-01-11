require 'active_support'

begin
  require 'semantic_record/support'
rescue LoadError
  support_path = "#{File.dirname(__FILE__)}/../../semantic_record/lib"
  if File.directory?(support_path)
    $:.unshift support_path
    require 'semantic_record/support'
  end
end

require 'semantic_record/base'
require 'semantic_record/property'
require 'semantic_record/triple_manager'
require 'semantic_record/connection_pool'
#require 'semantic_record/support'
require 'semantic_record/namespaces'
require 'semantic_record/foxen'
