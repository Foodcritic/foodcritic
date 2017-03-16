rule "FC049", "Role name does not match containing file name" do
  tags %w{style roles}
  role do |ast, filename|
    role_name_specified = field_value(ast, :name)
    role_name_file = Pathname.new(filename).basename.sub_ext("").to_s
    if role_name_specified && role_name_specified != role_name_file
      field(ast, :name)
    end
  end
end
