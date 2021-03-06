require 'rubygems'
gem 'activesupport', '=2.3.5'
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

require 'sparql'
require 'semantic_record/triple_manager'
require 'semantic_record/base'
require 'semantic_record/property'
require 'semantic_record/connection_pool'
require 'semantic_record/namespaces'
require 'semantic_record/foxen'
