rule "FC029", "No leading cookbook name in recipe metadata" do
  tags %w{correctness metadata}
  metadata do |ast, filename|
    field(ast, "recipe").map do |declared_recipe|
      next unless declared_recipe.xpath("count(//vcall|//var_ref)").to_i == 0

      recipe_name = declared_recipe.xpath('args_add_block/
        descendant::tstring_content[1]/@value').to_s
      unless recipe_name.empty? ||
          recipe_name.split("::").first == cookbook_name(filename.to_s)
        declared_recipe
      end
    end.compact
  end
end
