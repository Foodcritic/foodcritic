module FoodCritic
  module Template

    # Extract expressions <%= expr %> from Erb templates.
    class ExpressionExtractor

      include Erubis::Basic::Converter

      def initialize
        init_converter({})
      end

      def extract(template_code)
        @expressions = []
        convert(template_code)
        @expressions
      end

      def add_expr(src, code, indicator)
        if indicator == '='
          @expressions << {:type => :expression, :code => code.strip}
        end
      end

      def add_text(src, text)

      end

      def add_preamble(codebuf)

      end

      def add_postamble(codebuf)

      end

      def add_stmt(src, code)
        @expressions << {:type => :statement, :code => code.strip}
      end

    end

  end
end
