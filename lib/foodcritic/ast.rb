module FoodCritic
  module AST
    private

    def ast_hash_node?(node)
      node.first.respond_to?(:first) && node.first.first == :assoc_new
    end

    def ast_node_has_children?(node)
      node.respond_to?(:first) && !node.respond_to?(:match)
    end

    # If the provided node is the line / column information.
    def position_node?(node)
      node.respond_to?(:length) &&
        node.length == 2 &&
        node.respond_to?(:all?) &&
        node.all? { |child| child.respond_to?(:to_i) }
    end
  end
end
