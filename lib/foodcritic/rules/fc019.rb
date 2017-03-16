rule "FC019", "Access node attributes in a consistent manner" do
  tags %w{style attributes}
  cookbook do |cookbook_dir|
    asts = {}; files = Dir["#{cookbook_dir}/*/*.rb"].reject do |file|
      relative_path = Pathname.new(file).relative_path_from(
        Pathname.new(cookbook_dir))
      relative_path.to_s.split(File::SEPARATOR).include?("spec")
    end.map do |file|
      { path: file, ast: read_ast(file) }
    end
    types = [:string, :symbol, :vivified].map do |type|
      {
        access_type: type, count: files.map do |file|
          attribute_access(file[:ast], type: type, ignore_calls: true,
                                       cookbook_dir: cookbook_dir, ignore: "run_state").tap do |ast|
            unless ast.empty?
              (asts[type] ||= []) << { ast: ast, path: file[:path] }
            end
          end.size
        end.inject(:+)
      }
    end.reject { |type| type[:count] == 0 }
    if asts.size > 1
      least_used = asts[types.min do |a, b|
        a[:count] <=> b[:count]
      end[:access_type]]
      least_used.map do |file|
        file[:ast].map do |ast|
          match(ast).merge(filename: file[:path])
        end.flatten
      end
    end
  end
end
