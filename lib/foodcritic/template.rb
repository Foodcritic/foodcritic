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
        expressions(template_code)
      end

      def add_expr(src, code, indicator)
        if indicator == '='
          @expressions << { type: :expression, code: code.strip }
        end
      end

      def add_text(src, text)
      end

      def add_preamble(codebuf)
      end

      def add_postamble(codebuf)
      end

      def add_stmt(src, code)
        @expressions << { type: :statement, code: code.strip }
      end

      private

      def expressions(template_code)
        expr_lines = expressions_with_lines(template_code)
        expr_lines.map do |expr, line|
          e = @expressions.find { |e| e[:code] == expr }
          { code: expr, type: e[:type], line: line } if e
        end.compact
      end

      def expressions_with_lines(template_code)
        lines = lines_with_offsets(template_code)
        expression_offsets(template_code).map do |expr_offset, code|
          [code, lines.find { |line, offset| offset >= expr_offset }.first]
        end
      end

      def expression_offsets(template_code)
        expr_offsets = []
        template_code.scan(DEFAULT_REGEXP) do |m|
          expr_offsets << [Regexp.last_match.offset(0).first, m[1].strip]
        end
        expr_offsets
      end

      def lines_with_offsets(template_code)
        line_offsets = []
        template_code.scan(/$/) do |m|
          line_offsets << Regexp.last_match.offset(0).first
        end
        line_offsets.each_with_index.map { |pos, ln| [ln + 1, pos] }
      end
    end
  end
end
