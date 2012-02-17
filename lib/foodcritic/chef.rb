module FoodCritic

  # Encapsulates functions that previously were calls to the Chef gem.
  module Chef

    def load_metadata
      metadata_path = File.join(File.dirname(__FILE__), '..', '..', 'chef_dsl_metadata.json')
      @dsl_metadata ||= Yajl::Parser.parse(IO.read(metadata_path), :symbolize_keys => true)
    end

    # The set of methods in the Chef DSL
    #
    # @return [Array] Array of method symbols
    def dsl_methods
      load_metadata
      @dsl_metadata[:dsl_methods].map{|m| m.to_sym}
    end

    # Is the specified attribute valid for the type of resource?
    #
    # @param [Symbol] resource_type The type of Chef resource
    # @param [Symbol] attribute_name The attribute name
    def attribute?(resource_type, attribute_name)
      load_metadata
      resource_attributes = @dsl_metadata[:attributes]
      return true unless resource_attributes.include?(resource_type)
      resource_attributes[resource_type].include?(attribute_name.to_s)
    end

    module Search

      # The search grammars that ship with any Chef gems installed locally.
      # These are returned in descending version order (a newer Chef version
      #   could break our ability to load the grammar).
      #
      # @return [Array] File paths of Chef search grammars installed locally.
      def chef_search_grammars
        Gem.path.map do |gem_path|
          Dir["#{gem_path}/gems/chef-*/**/lucene.treetop"]
        end.flatten.sort.reverse
      end

      # Create the search parser from the first loadable grammar.
      #
      # @param [Array] grammar_paths Full paths to candidate treetop grammars
      def load_search_parser(grammar_paths)
        @search_parser ||= grammar_paths.inject(nil) do |parser,lucene_grammar|
            begin
              break parser unless parser.nil?
              # don't instantiate custom nodes
              Treetop.load_from_string(IO.read(lucene_grammar).gsub(/<[^>]+>/, ''))
              LuceneParser.new
            rescue
              # silently swallow and try the next grammar
            end
        end
      end

      # Has the search parser been loaded?
      #
      # @return [Boolean] True if the search parser has been loaded.
      def search_parser_loaded?
        ! @search_parser.nil?
      end

      # Is this a valid Lucene query?
      #
      # @param [String] query The query to check for syntax errors
      # @return [Boolean] True if the query is well-formed
      def valid_query?(query)
       load_search_parser(chef_search_grammars)
       search_parser_loaded? ? (! @search_parser.parse(query).nil?) : true
      end
    end
  end

end
