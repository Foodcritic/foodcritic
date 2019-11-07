rule "FC033", "Missing template file" do
  tags %w{correctness templates}
  recipe do |ast, filename|
    # find all template resources that don't fetch a template
    # from either another cookbook or a local path
    find_resources(ast, type: :template).reject do |resource|
      resource_attributes(resource)["local"] ||
        resource_attributes(resource)["cookbook"]
    end.map do |resource|
      # fetch the specified file to the template
      file = template_file(resource_attributes(resource,
        return_expressions: true))
      { resource: resource, file: file }
    end.reject do |resource|
      # skip the check if the file path is derived since
      # we can't determine if that's here or not without converging the node
      resource[:file].respond_to?(:xpath)
    end.select do |resource|
      template_paths(filename).none? do |path|
        relative_path = []
        Pathname.new(path).ascend do |template_path|
          relative_path << template_path.basename
          # stop building relative path if we've hit template or 1 dir above
          # NOTE: This is a totally flawed attempt to strip things like
          # templates/ubuntu/something.erb down to something.erb, which breaks
          # legit nested dirs in the templates dir like templates/something/something.erb
          break if template_path.dirname.basename.to_s == "templates" ||
            template_path.dirname.dirname.basename.to_s == "templates"
        end
        File.join(relative_path.reverse) == resource[:file]
      end
    end.map { |resource| resource[:resource] }
  end
end
