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

require 'semantic_record/result_parser_json'
require 'semantic_record/sesame_adapter'
require 'semantic_record/transaction_factory'
require 'semantic_record/base'
