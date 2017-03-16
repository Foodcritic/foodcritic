rule "FC014", "Consider extracting long ruby_block to library" do
  tags %w{style libraries}
  recipe do |ast|
    find_resources(ast, type: "ruby_block").find_all do |rb|
      lines = rb.xpath("descendant::fcall[ident/@value='block']/../../
        descendant::*[@line]/@line").map { |n| n.value.to_i }.sort
      (!lines.empty?) && (lines.last - lines.first) > 15
    end
  end
end
