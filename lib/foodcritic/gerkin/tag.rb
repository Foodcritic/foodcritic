# this is vendored from cucumber-core gem with the module/class names changed

module Foodcritic
  module Gherkin
    class Tag

      attr_reader :name

      def initialize(location, name)
        @location = location
        @name = name
      end

      def inspect
        %{#<#{self.class} "#{name}" (#{location})>}
      end

      def file_colon_line
        location.to_s
      end

      def file
        location.file
      end

      def line
        location.line
      end

      def location
        raise('Please set @location in the constructor') unless defined?(@location)
        @location
      end

      def attributes
        [tags, comments, multiline_arg].flatten
      end

      def tags
        # will be overriden by nodes that actually have tags
        []
      end

      def comments
        # will be overriden by nodes that actually have comments
        []
      end

      def multiline_arg
        # will be overriden by nodes that actually have a multiline_argument
        Test::EmptyMultilineArgument.new
      end
    end
  end
end
