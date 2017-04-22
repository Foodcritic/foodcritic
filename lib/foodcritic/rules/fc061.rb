rule "FC061", "Valid cookbook versions are of the form x.y or x.y.z" do
  tags %w{metadata correctness supermarket}
  metadata do |ast, filename|
    # matches a version method with a string literal with no interpolation
    ver = field_value(ast, 'version')
    if ver && !ver.empty? && ver.to_s !~ /\A\d+\.\d+(\.\d+)?\z/
      field(ast, 'version')
    end
  end
end
