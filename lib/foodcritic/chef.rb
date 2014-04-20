module FoodCritic
  # Encapsulates functions that previously were calls to the Chef gem.
  module Chef
    def chef_dsl_methods
      load_metadata
      @dsl_metadata[:dsl_methods].map(&:to_sym)
    end

    def chef_node_methods
      load_metadata
      @dsl_metadata[:node_methods].map(&:to_sym)
    end

    # Is the specified action valid for the type of resource?
    def resource_action?(resource_type, action)
      resource_check?(:actions, resource_type, action)
    end

    # Is the specified attribute valid for the type of resource?
    def resource_attribute?(resource_type, attribute_name)
      resource_check?(:attributes, resource_type, attribute_name)
    end

    # Is this a valid Lucene query?
    def valid_query?(query)
      fail ArgumentError, 'Query cannot be nil or empty' if query.to_s.empty?

      # Attempt to create a search query parser
      search = FoodCritic::Chef::Search.new
      search.create_parser(search.chef_search_grammars)

      if search.parser?
        search.parser.parse(query.to_s)
      else
        # If we didn't manage to get a parser then we can't know if the query
        # is valid or not.
        true
      end
    end

    private

    # To avoid the runtime hit of loading the Chef gem and its dependencies
    # we load the DSL metadata from a JSON file shipped with our gem.
    #
    # The DSL metadata doesn't necessarily reflect the version of Chef in the
    # local user gemset.
    def load_metadata
      version = if self.respond_to?(:chef_version)
                  chef_version
                else
                  Linter::DEFAULT_CHEF_VERSION
                end
      metadata_path = [version, version.sub(/\.[a-z].*/, ''),
        Linter::DEFAULT_CHEF_VERSION].map do |version|
          metadata_path(version)
        end.find { |m| File.exist?(m) }
      @dsl_metadata ||= Yajl::Parser.parse(IO.read(metadata_path),
                                           symbolize_keys: true)
    end

    def metadata_path(chef_version)
      File.join(File.dirname(__FILE__), '..', '..',
                "chef_dsl_metadata/chef_#{chef_version}.json")
    end

    def resource_check?(key, resource_type, field)
      if resource_type.to_s.empty? || field.to_s.empty?
        fail ArgumentError, 'Arguments cannot be nil or empty.'
      end

      load_metadata
      resource_fields = @dsl_metadata[key]

      # If the resource type is not recognised then it may be a user-defined
      # resource. We could introspect these but at present we simply return
      # true.
      return true unless resource_fields.include?(resource_type.to_sym)

      # Otherwise the resource field must exist in our metadata to succeed
      resource_fields[resource_type.to_sym].include?(field.to_s)
    end

    class Search
      # The search grammars that ship with any Chef gems installed locally.
      # These are returned in descending version order (a newer Chef version
      #   could break our ability to load the grammar).
      # Grammars are not available from Chef 11+.
      def chef_search_grammars
        Gem.path.map do |gem_path|
          Dir["#{gem_path}/gems/chef-*/**/lucene.treetop"]
        end.flatten.sort.reverse
      end

      # Create the search parser from the first loadable grammar.
      def create_parser(grammar_paths)
        @search_parser ||=
          grammar_paths.inject(nil) do |parser, lucene_grammar|
          begin
            break parser unless parser.nil?
            # Don't instantiate custom nodes
            Treetop.load_from_string(
              IO.read(lucene_grammar).gsub(/<[^>]+>/, ''))
            LuceneParser.new
          rescue
            # Silently swallow and try the next grammar
          end
        end
      end

      # Has the search parser been loaded?
      def parser?
        ! @search_parser.nil?
      end

      # The search parser
      def parser
        @search_parser
      end
    end
  end
end
