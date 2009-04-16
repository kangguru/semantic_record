#require "ruby-sesame"

module ActiveSemantic
  class Base
    include SesameAdapter

    def Base.inherited(subClass)

      ###
      ### attribute accessors that are independet from superclass
      ###
      class << self
        attr_accessor :rdf_type, :attributes, :base_uri, :attributes_names
      end

      subClass.base_uri="http://example.org/music#"
      subClass.rdf_type = subClass.name#.split("::").last.to_s
      subClass.attributes = {}

      def subClass.construct_attributes
        self.attributes, self.attributes_names = ResultParserJson.hash_values(self.query("SELECT ?property_name ?property_type WHERE { ?property_name rdfs:domain <#{uri}>; rdfs:range ?property_type }"))
      end

      def subClass.uri
        # TODO change my name
        "#{base_uri}#{rdf_type}"
      end

      def subClass.find(uri_or_scope)
        self.query("SELECT ?instance WHERE { ?instance rdf:type <#{uri}>}")
      end

      def subClass.attributes_names
        attributes.keys.collect {|key|
          key.to_human_name
        }
      end

      ###
      ### class initializer calls
      ###

      subClass.construct_attributes

    end
  end
end