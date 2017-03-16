rule "FC061", "Valid cookbook versions are of the form x.y or x.y.z" do
  tags %w{metadata correctness}
  metadata do |ast, filename|
    # matches a version method with a string literal with no interpolation
    ver = ast.xpath('//command[ident/@value="version"]/args_add_block/args_add/string_literal[not(.//string_embexpr)]//tstring_content/@value')
    if !ver.empty? && ver.to_s !~ /\A\d+\.\d+(\.\d+)?\z/
      [file_match(filename)]
    end
  end
end
