rule "FC033", "Missing template" do
  tags %w{correctness templates}
  recipe do |ast, filename|
    find_resources(ast, type: :template).reject do |resource|
      resource_attributes(resource)["local"] ||
        resource_attributes(resource)["cookbook"]
    end.map do |resource|
      file = template_file(resource_attributes(resource,
                                               return_expressions: true))
      { resource: resource, file: file }
    end.reject do |resource|
      resource[:file].respond_to?(:xpath)
    end.select do |resource|
      template_paths(filename).none? do |path|
        relative_path = []
        Pathname.new(path).ascend do |template_path|
          relative_path << template_path.basename
          break if gem_version(chef_version) >= gem_version("12.0.0") &&
              template_path.dirname.basename.to_s == "templates"
          break if template_path.dirname.dirname.basename.to_s == "templates"
        end
        File.join(relative_path.reverse) == resource[:file]
      end
    end.map { |resource| resource[:resource] }
  end
end
