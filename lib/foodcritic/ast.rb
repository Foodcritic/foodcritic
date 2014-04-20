module FoodCritic
  module AST

    private

    def ast_hash_node?(node)
      node.first.respond_to?(:first) and node.first.first == :assoc_new
    end

    def ast_node_has_children?(node)
      node.respond_to?(:first) and ! node.respond_to?(:match)
    end

    # If the provided node is the line / column information.
    def position_node?(node)
      node.respond_to?(:length) and node.length == 2 and
        node.respond_to?(:all?) and node.all? { |child| child.respond_to?(:to_i) }
    end

  end

end
